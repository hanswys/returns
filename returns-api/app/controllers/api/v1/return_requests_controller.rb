module Api
  module V1
    class ReturnRequestsController < BaseController
      before_action :set_return_request, only: [:show, :update, :destroy, :approve, :reject, :ship, :mark_received, :resolve]

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
        # Check for idempotency - return existing request if duplicate
        if params[:return_request][:idempotency_key].present?
          existing = ReturnRequest.find_by(idempotency_key: params[:return_request][:idempotency_key])
          if existing
            return render json: existing, serializer: ReturnRequestSerializer, status: :ok
          end
        end

        @return_request = ReturnRequest.new(return_request_params)
        
        # Enforce return rules before accepting request
        eligibility_check = check_eligibility(@return_request)
        unless eligibility_check[:eligible]
          return render json: { 
            error: 'Return not allowed', 
            reason: eligibility_check[:reason],
            details: eligibility_check[:details]
          }, status: :unprocessable_entity
        end

        if @return_request.save
          # Trigger background job to generate shipping label
          GenerateShippingLabelJob.perform_later(@return_request.id)
          
          render json: @return_request, serializer: ReturnRequestSerializer, status: :created
        else
          render json: { errors: @return_request.errors }, status: :unprocessable_entity
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
        if @return_request.approve!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot approve return request' }, status: :unprocessable_entity
        end
      end

      def reject
        if @return_request.reject!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot reject return request' }, status: :unprocessable_entity
        end
      end

      def ship
        if @return_request.ship!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot ship return request' }, status: :unprocessable_entity
        end
      end

      def mark_received
        if @return_request.mark_received!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot mark return request as received' }, status: :unprocessable_entity
        end
      end

      def resolve
        if @return_request.resolve!
          render json: @return_request, serializer: ReturnRequestSerializer
        else
          render json: { error: 'Cannot resolve return request' }, status: :unprocessable_entity
        end
      end

      private

      def set_return_request
        @return_request = ReturnRequest.find(params[:id])
      end

      def return_request_params
        params.require(:return_request).permit(:order_id, :product_id, :merchant_id, :reason, :requested_date, :status, :idempotency_key)
      end

      def check_eligibility(return_request)
        order = return_request.order
        merchant = return_request.merchant

        # Find the applicable return rule for this merchant
        return_rule = ReturnRule.find_by(merchant_id: merchant&.id)

        # If no return rule exists, deny by default
        unless return_rule
          return {
            eligible: false,
            reason: 'no_return_policy',
            details: 'This merchant does not have a return policy configured'
          }
        end

        # Use the Evaluator to check eligibility
        decision = return_rule.eligible?(order)

        if decision.status == :approve
          { eligible: true }
        else
          {
            eligible: false,
            reason: decision.reason || 'not_eligible',
            details: build_rejection_details(return_rule, order)
          }
        end
      end

      def build_rejection_details(return_rule, order)
        window_days = return_rule.configuration['window_days']
        order_date = order.order_date.to_date
        deadline = order_date + window_days.days
        days_since = (Date.current - order_date).to_i

        "Return window is #{window_days} days. Order was placed #{days_since} days ago (#{order_date.strftime('%B %d, %Y')}). Return deadline was #{deadline.strftime('%B %d, %Y')}."
      end
    end
  end
end
