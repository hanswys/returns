# frozen_string_literal: true

module Api
  module V1
    # Concern to handle AASM state transitions with audit logging
    # Extracts common pattern from ReturnRequestsController
    module AasmActions
      extend ActiveSupport::Concern

      included do
        # Define which actions use this concern
        AASM_TRANSITIONS = {
          approve: { event: :approve!, error: 'Cannot approve return request' },
          reject: { event: :reject!, error: 'Cannot reject return request' },
          ship: { event: :ship!, error: 'Cannot ship return request' },
          mark_received: { event: :mark_received!, error: 'Cannot mark return request as received' },
          resolve: { event: :resolve!, error: 'Cannot resolve return request' }
        }.freeze
      end

      # Generic transition handler
      def perform_transition(action)
        config = self.class::AASM_TRANSITIONS[action]
        raise "Unknown action: #{action}" unless config

        Current.actor = determine_actor
        if @return_request.send(config[:event])
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: config[:error] }, status: :unprocessable_entity
        end
      rescue AASM::InvalidTransition => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def determine_actor
        # Override in controller if needed
        'admin:api'
      end
    end
  end
end
