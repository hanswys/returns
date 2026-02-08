# frozen_string_literal: true

# Service for creating multiple return requests atomically
# All requests succeed or all fail together (transactional)
#
# Usage:
#   result = BatchReturnRequestCreator.call(params)
#   if result.success?
#     result.return_requests  # Array of created requests
#   else
#     result.error_response
#   end
#
class BatchReturnRequestCreator
  BatchResult = Struct.new(:success?, :return_requests, :error_response, keyword_init: true)

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @order_id = params[:order_id]
    @merchant_id = params[:merchant_id]
    @reason = params[:reason]
    @items = params[:items] || []
    @requested_date = params[:requested_date] || Date.current
    @idempotency_key = params[:idempotency_key]
  end

  def call
    return empty_items_error if @items.empty?

    # Check for idempotency on batch level
    if @idempotency_key.present?
      existing = ReturnRequest.where(idempotency_key: batch_idempotency_keys).to_a
      return success_result(existing) if existing.size == @items.size
    end

    created_requests = []

    ActiveRecord::Base.transaction do
      @items.each_with_index do |item, index|
        result = create_single_request(item, index)

        unless result[:success]
          raise ActiveRecord::Rollback, result[:error]
        end

        created_requests << result[:request]
      end
    end

    # Check if transaction was rolled back
    if created_requests.size == @items.size && created_requests.all?(&:persisted?)
      # Enqueue label generation for all
      created_requests.each do |request|
        GenerateShippingLabelJob.perform_later(request.id)
      end
      success_result(created_requests)
    else
      failure_result(
        error: 'Batch creation failed',
        reason: 'transaction_rolled_back',
        details: 'One or more items failed validation. No returns were created.'
      )
    end
  end

  private

  def create_single_request(item, index)
    params = {
      order_id: @order_id,
      merchant_id: @merchant_id,
      product_id: item[:product_id],
      reason: build_reason(item),
      requested_date: @requested_date,
      idempotency_key: @idempotency_key ? "#{@idempotency_key}_#{index}" : nil
    }

    return_request = ReturnRequest.new(params)

    # Check eligibility
    eligibility = check_eligibility(return_request)
    unless eligibility[:eligible]
      return {
        success: false,
        error: {
          product_id: item[:product_id],
          reason: eligibility[:reason],
          details: eligibility[:details]
        }
      }
    end

    if return_request.save
      { success: true, request: return_request }
    else
      { success: false, error: { product_id: item[:product_id], errors: return_request.errors.full_messages } }
    end
  end

  def build_reason(item)
    item[:notes].present? ? "#{@reason}: #{item[:notes]}" : @reason
  end

  def batch_idempotency_keys
    @items.each_index.map { |i| "#{@idempotency_key}_#{i}" }
  end

  # Delegate to EligibilityChecker service (DRY - single source of truth)
  def check_eligibility(return_request)
    result = EligibilityChecker.call(return_request)

    if result.eligible?
      { eligible: true }
    else
      {
        eligible: false,
        reason: result.reason,
        details: result.details
      }
    end
  end

  def empty_items_error
    failure_result(
      error: 'No items provided',
      reason: 'empty_items',
      details: 'At least one item must be selected for return'
    )
  end

  def success_result(requests)
    BatchResult.new(success?: true, return_requests: requests)
  end

  def failure_result(error_data)
    BatchResult.new(success?: false, error_response: error_data)
  end
end
