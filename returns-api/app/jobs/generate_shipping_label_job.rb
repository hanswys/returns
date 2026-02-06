# frozen_string_literal: true

# Background job that simulates requesting a shipping label from a carrier.
# Includes a delay to simulate the O2O (Online-to-Offline) flow.
class GenerateShippingLabelJob < ApplicationJob
  queue_as :default

  # Retry on failures with exponential backoff
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(return_request_id)
    return_request = ReturnRequest.find(return_request_id)
    
    # Only process if still in 'requested' state
    return unless return_request.requested?

    Rails.logger.info "[ShippingLabel] Starting label generation for ReturnRequest ##{return_request_id}"

    # Simulate carrier API delay (5 seconds)
    simulate_carrier_delay

    # Generate the shipping label
    label_data = ShippingLabelGenerator.new(return_request).generate

    # Update return request with label info
    return_request.update!(
      tracking_number: label_data[:tracking_number],
      carrier: label_data[:carrier],
      label_url: label_data[:label_url]
    )

    # Transition to approved state
    return_request.approve!

    Rails.logger.info "[ShippingLabel] Label generated for ReturnRequest ##{return_request_id}: #{label_data[:tracking_number]}"
  end

  private

  def simulate_carrier_delay
    Rails.logger.info "[ShippingLabel] Simulating carrier API call (5 second delay)..."
    sleep(5)
    Rails.logger.info "[ShippingLabel] Carrier API response received"
  end
end
