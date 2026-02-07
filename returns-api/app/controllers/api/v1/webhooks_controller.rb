# frozen_string_literal: true

module Api
  module V1
    # Handles webhook callbacks from external services
    # Currently supports carrier status updates
    class WebhooksController < BaseController
      skip_before_action :verify_authenticity_token, raise: false

      # POST /api/v1/webhooks/carrier
      # Accepts status updates from carriers (e.g., package received)
      #
      # Expected payload:
      # {
      #   "tracking_number": "ABC-123",
      #   "status": "received",
      #   "timestamp": "2026-02-05T12:00:00Z"
      # }
      def carrier
        tracking_number = params[:tracking_number]
        status = params[:status]

        unless tracking_number.present? && status.present?
          return render json: { error: 'tracking_number and status are required' }, status: :bad_request
        end

        return_request = ReturnRequest.find_by(tracking_number: tracking_number)

        unless return_request
          return render json: { error: 'Return request not found' }, status: :not_found
        end

        # Set actor for audit logging
        Current.actor = 'webhook:carrier'
        result = process_carrier_status(return_request, status)

        if result[:success]
          render json: {
            message: 'Status updated successfully',
            return_request_id: return_request.id,
            new_status: return_request.status
          }, status: :ok
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      private

      def process_carrier_status(return_request, status)
        case status.downcase
        when 'shipped'
          transition_if_possible(return_request, :ship!)
        when 'received', 'delivered'
          transition_if_possible(return_request, :mark_received!)
        when 'resolved', 'completed'
          transition_if_possible(return_request, :resolve!)
        else
          { success: false, error: "Unknown status: #{status}" }
        end
      end

      def transition_if_possible(return_request, event)
        if return_request.send(event)
          { success: true }
        else
          { success: false, error: "Cannot transition to #{event}" }
        end
      rescue AASM::InvalidTransition => e
        { success: false, error: e.message }
      end
    end
  end
end
