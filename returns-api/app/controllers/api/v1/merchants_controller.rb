module Api
  module V1
    class MerchantsController < BaseController
      # execute set_merchant before show, update, and destroy functions
      before_action :set_merchant, only: [:show, :update, :destroy]

      def index
        @merchants = Merchant.all # AR Object
        render json: @merchants, each_serializer: MerchantSerializer #turns AR Object into array and loops through each object
        # return JSON
      end

      def show
        render json: @merchant, serializer: MerchantSerializer
      end

      def create
        @merchant = Merchant.new(merchant_params)
        if @merchant.save
          render json: @merchant, serializer: MerchantSerializer, status: :created # return status code 201
        else
          render json: { errors: @merchant.errors }, status: :unprocessable_entity # return status code 422
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
        # from model only require these fields
        params.require(:merchant).permit(:name, :email, :contact_person, :address, :status)
      end
    end
  end
end
