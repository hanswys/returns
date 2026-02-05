module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from AASM::InvalidTransition, with: :invalid_state_transition

      protected

      def record_not_found
        render json: { error: 'Record not found' }, status: :not_found
      end

      def parameter_missing(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end

      def invalid_state_transition
        render json: { error: 'Invalid state transition' }, status: :unprocessable_entity
      end
    end
  end
end
