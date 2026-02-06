# frozen_string_literal: true

# Background job that simulates requesting a shipping label from a carrier.
# Includes a delay to simulate the O2O (Online-to-Offline) flow.
#
# Error handling:
# - Retries 3 times with exponential backoff
# - Discards job if return request not found
# - Records failure details on final failure
#
class GenerateShippingLabelJob < ApplicationJob
  queue_as :default

  # Retry on transient failures with exponential backoff
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Don't retry if the record doesn't exist
  discard_on ActiveRecord::RecordNotFound

  def perform(return_request_id)
    @return_request = ReturnRequest.find(return_request_id)

    # Only process if still in 'requested' state
    unless @return_request.requested?
      Rails.logger.info "[ShippingLabel] Skipping ReturnRequest ##{return_request_id} - already processed (status: #{@return_request.status})"
      return
    end

    Rails.logger.info "[ShippingLabel] Starting label generation for ReturnRequest ##{return_request_id}"

    generate_label
  rescue StandardError => e
    handle_failure(e)
    raise # Re-raise to trigger retry logic
  end

  private

  def generate_label
    # Simulate carrier API delay (5 seconds)
    simulate_carrier_delay

    # Generate the shipping label
    label_data = ShippingLabelGenerator.new(@return_request).generate

    # Update return request with label info
    @return_request.update!(
      tracking_number: label_data[:tracking_number],
      carrier: label_data[:carrier],
      label_url: label_data[:label_url],
      label_generation_failed_at: nil,
      label_generation_error: nil
    )

    # Transition to approved state
    @return_request.approve!

    Rails.logger.info "[ShippingLabel] Label generated for ReturnRequest ##{@return_request.id}: #{label_data[:tracking_number]}"
  end

  def handle_failure(error)
    Rails.logger.error "[ShippingLabel] Failed to generate label for ReturnRequest ##{@return_request.id}: #{error.message}"

    # Record the failure for visibility
    @return_request.update_columns(
      label_generation_failed_at: Time.current,
      label_generation_error: "#{error.class}: #{error.message}"
    )
  end

  def simulate_carrier_delay
    Rails.logger.info "[ShippingLabel] Simulating carrier API call (5 second delay)..."
    sleep(5)
    Rails.logger.info "[ShippingLabel] Carrier API response received"
  end
end
