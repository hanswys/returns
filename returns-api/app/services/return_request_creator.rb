# frozen_string_literal: true

# Service object for creating return requests
# Extracts business logic from ReturnRequestsController following SRP
#
# Usage:
#   result = ReturnRequestCreator.call(params)
#   if result.success?
#     result.return_request
#   else
#     result.error_response
#   end
#
class ReturnRequestCreator
  Result = Struct.new(:success?, :return_request, :error_response, :status_code, keyword_init: true)

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    # Check for idempotency - return existing request if duplicate
    if idempotency_key.present?
      existing = ReturnRequest.find_by(idempotency_key: idempotency_key)
      return success_result(existing, status: :ok) if existing
    end

    return_request = ReturnRequest.new(@params)

    # Validate eligibility using dedicated service (SRP)
    eligibility = EligibilityChecker.call(return_request) 
    unless eligibility.eligible?
      return failure_result(
        error: 'Return not allowed',
        reason: eligibility.reason,
        details: eligibility.details
      )
    end

    # Save and enqueue job
    if return_request.save
      GenerateShippingLabelJob.perform_later(return_request.id)
      success_result(return_request, status: :created)
    else
      failure_result(errors: return_request.errors)
    end
  end

  private

  def idempotency_key
    @params[:idempotency_key]
  end

  def success_result(return_request, status:)
    Result.new(
      success?: true,
      return_request: return_request,
      status_code: status
    )
  end

  def failure_result(error_data)
    Result.new(
      success?: false,
      error_response: error_data,
      status_code: :unprocessable_entity
    )
  end
end

