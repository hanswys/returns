module Api
  module V1
    class ReturnRequestsController < CustomerBaseController
      skip_before_action :authenticate_customer!, only: [:index, :by_merchant, :approve, :reject, :ship, :mark_received, :resolve, :audit_logs]
      before_action :set_return_request, only: [:show, :update, :destroy, :approve, :reject, :ship, :mark_received, :resolve, :audit_logs]

      # Merchant/Admin endpoints (Unsecured for now per instructions, to be secured later)
      def index
        @return_requests = ReturnRequest.includes(:order, :product, :merchant).all
        render json: @return_requests, each_serializer: ReturnRequestSerializer
      end

      # GET /api/v1/merchants/:merchant_id/returns
      def by_merchant
        @return_requests = ReturnRequest.includes(:order, :product, :merchant)
          .where(merchant_id: params[:merchant_id])
        @return_requests = @return_requests.where(status: params[:status]) if params[:status].present?
        @return_requests = @return_requests.order(created_at: :desc)
        render json: @return_requests, each_serializer: ReturnRequestSerializer
      end

      # Customer endpoint - Secured by authenticate_customer!
      # GET /api/v1/return_requests/:id
      def show
        # Ensure the return request belongs to the authenticated order
        unless @return_request.order_id == current_customer_context.order_id
          render json: { error: 'Unauthorized access to this return request' }, status: :forbidden
          return
        end

        render json: @return_request, serializer: ReturnRequestSerializer
      end

      # Customer endpoint - Secured by authenticate_customer!
      # POST /api/v1/return_requests
      def create
        # Enforce that the request is for the authenticated order
        unless return_request_params[:order_id].to_i == current_customer_context.order_id
          render json: { error: 'Unauthorized: Cannot create return for another order' }, status: :forbidden
          return
        end

        result = ReturnRequestCreator.call(return_request_params) # calls self.call

        if result.success?
          render json: result.return_request, serializer: ReturnRequestSerializer, status: result.status_code
        else
          render json: result.error_response, status: :unprocessable_entity
        end
      end

      # Assuming update/destroy are for customers fixing mistakes before processing? 
      # Or maybe admins? Leaving strict scoping for now.
      def update
        unless @return_request.order_id == current_customer_context.order_id
          render json: { error: 'Unauthorized' }, status: :forbidden
          return
        end

        if @return_request.update(return_request_params)
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { errors: @return_request.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        unless @return_request.order_id == current_customer_context.order_id
           render json: { error: 'Unauthorized' }, status: :forbidden
           return
        end

        @return_request.destroy
        head :no_content
      end

      # AASM transition actions - using concern pattern
      # These remain skip_before_action :authenticate_customer! (Merchant/System actions)
      include Api::V1::AasmActions

      def approve
        perform_transition(:approve)
      end

      def reject
        perform_transition(:reject)
      end

      def ship
        perform_transition(:ship)
      end

      def mark_received
        perform_transition(:mark_received)
      end

      def resolve
        perform_transition(:resolve)
      end

      # GET /api/v1/return_requests/:id/audit_logs
      def audit_logs
        logs = @return_request.status_audit_logs.recent
        render json: logs, each_serializer: StatusAuditLogSerializer
      end

      # POST /api/v1/return_requests/batch
      # Batch creation - scoped to customer
      def create_batch
         # Verify order_id in params matches token
         unless batch_params[:order_id].to_i == current_customer_context.order_id
            render json: { error: 'Unauthorized' }, status: :forbidden
            return
         end

        result = BatchReturnRequestCreator.call(batch_params)

        if result.success?
          render json: result.return_requests, each_serializer: ReturnRequestSerializer, status: :created
        else
          render json: result.error_response, status: :unprocessable_entity
        end
      end

      private

      def set_return_request
        @return_request = ReturnRequest.find(params[:id])
      end

      def return_request_params
        params.require(:return_request).permit(:order_id, :product_id, :merchant_id, :reason, :requested_date, :status, :idempotency_key)
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

