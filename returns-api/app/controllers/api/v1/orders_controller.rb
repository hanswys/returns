module Api
  module V1
    class OrdersController < BaseController
      before_action :set_order, only: [:show, :update, :destroy]

      def index
        @orders = Order.all
        render json: @orders, each_serializer: OrderSerializer
      end

      # Customer portal order lookup
      # GET /api/v1/orders/lookup?email=...&order_number=...
      def lookup
        @order = Order.find_by(
          customer_email: params[:email],
          order_number: params[:order_number]
        )

        if @order
          token = JsonWebToken.encode(order_id: @order.id, customer_email: @order.customer_email)
          # Preload return_requests for the serializer to avoid N+1
          @order.return_requests.load 
          
          render json: {
            order: OrderSerializer.new(@order, include: ['order_items']).as_json,
            token: token
          }
        else
          render json: { error: 'Order not found' }, status: :not_found
        end
      end

      def show
        render json: @order, serializer: OrderSerializer
      end

      def create
        @order = Order.new(order_params)
        if @order.save
          render json: @order, serializer: OrderSerializer, status: :created
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @order.update(order_params)
          render json: @order, serializer: OrderSerializer
        else
          render json: { errors: @order.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @order.destroy
        head :no_content
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def order_params
        params.require(:order).permit(:order_number, :customer_email, :customer_name, :merchant_id, :total_amount, :order_date, :status)
      end
    end
  end
end
