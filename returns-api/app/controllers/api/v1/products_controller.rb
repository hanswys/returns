module Api
  module V1
    class ProductsController < BaseController
      before_action :set_merchant
      before_action :set_product, only: [:show, :update, :destroy]

      def index
        @products = @merchant.products
        render json: @products, each_serializer: ProductSerializer
      end

      def show
        render json: @product, serializer: ProductSerializer
      end

      def create
        @product = @merchant.products.new(product_params)
        if @product.save
          render json: @product, serializer: ProductSerializer, status: :created
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: @product, serializer: ProductSerializer
        else
          render json: { errors: @product.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @product.destroy
        head :no_content
      end

      private

      def set_merchant
        @merchant = Merchant.find(params[:merchant_id])
      end

      def set_product
        @product = @merchant.products.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :sku, :description, :price)
      end
    end
  end
end
