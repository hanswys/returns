module Api
  module V1
    class MerchantsController < BaseController
      before_action :set_merchant, only: [:show, :update, :destroy]

      def index
        @merchants = Merchant.all
        render json: @merchants, each_serializer: MerchantSerializer
      end

      def show
        render json: @merchant, serializer: MerchantSerializer
      end

      def create
        @merchant = Merchant.new(merchant_params)
        if @merchant.save
          render json: @merchant, serializer: MerchantSerializer, status: :created
        else
          render json: { errors: @merchant.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @merchant.update(merchant_params)
          render json: @merchant, serializer: MerchantSerializer
        else
          render json: { errors: @merchant.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @merchant.destroy
        head :no_content
      end

      private

      def set_merchant
        @merchant = Merchant.find(params[:id])
      end

      def merchant_params
        params.require(:merchant).permit(:name, :email, :contact_person, :address, :status)
      end
    end
  end
end
