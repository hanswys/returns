module Api
  module V1
    class ReturnRequestsController < BaseController
      before_action :set_return_request, only: [:show, :update, :destroy, :approve, :reject, :ship, :mark_received, :resolve, :audit_logs]

      def index
        @return_requests = ReturnRequest.all
        render json: @return_requests, each_serializer: ReturnRequestSerializer
      end

      # GET /api/v1/merchants/:merchant_id/returns
      def by_merchant
        @return_requests = ReturnRequest.where(merchant_id: params[:merchant_id])
        @return_requests = @return_requests.where(status: params[:status]) if params[:status].present?
        @return_requests = @return_requests.order(created_at: :desc)
        render json: @return_requests, each_serializer: ReturnRequestSerializer
      end

      def show
        render json: @return_request, serializer: ReturnRequestSerializer
      end

      def create
        result = ReturnRequestCreator.call(return_request_params)

        if result.success?
          render json: result.return_request, serializer: ReturnRequestSerializer, status: result.status_code
        else
          render json: result.error_response, status: :unprocessable_entity
        end
      end

      def update
        if @return_request.update(return_request_params)
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { errors: @return_request.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @return_request.destroy
        head :no_content
      end

      def approve
        Current.actor = 'admin:api'
        if @return_request.approve!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot approve return request' }, status: :unprocessable_entity
        end
      end

      def reject
        Current.actor = 'admin:api'
        if @return_request.reject!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot reject return request' }, status: :unprocessable_entity
        end
      end

      def ship
        Current.actor = 'admin:api'
        if @return_request.ship!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot ship return request' }, status: :unprocessable_entity
        end
      end

      def mark_received
        Current.actor = 'admin:api'
        if @return_request.mark_received!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot mark return request as received' }, status: :unprocessable_entity
        end
      end

      def resolve
        Current.actor = 'admin:api'
        if @return_request.resolve!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot resolve return request' }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/return_requests/:id/audit_logs
      def audit_logs
        logs = @return_request.status_audit_logs.recent
        render json: logs, each_serializer: StatusAuditLogSerializer
      end

      private

      def set_return_request
        @return_request = ReturnRequest.find(params[:id])
      end

      def return_request_params
        params.require(:return_request).permit(:order_id, :product_id, :merchant_id, :reason, :requested_date, :status, :idempotency_key)
      end

      # POST /api/v1/return_requests/batch
      def create_batch
        result = BatchReturnRequestCreator.call(batch_params)

        if result.success?
          render json: result.return_requests, each_serializer: ReturnRequestSerializer, status: :created
        else
          render json: result.error_response, status: :unprocessable_entity
        end
      end

      def batch_params
        params.permit(
          :order_id,
          :merchant_id,
          :reason,
          :idempotency_key,
          items: [:product_id, :notes]
        )
      end
    end
  end
end
