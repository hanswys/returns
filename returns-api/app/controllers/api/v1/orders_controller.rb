module Api
  module V1
    class OrdersController < BaseController
      before_action :set_order, only: [:show, :update, :destroy]

      def index
        @orders = Order.all
        render json: @orders, each_serializer: OrderSerializer
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
