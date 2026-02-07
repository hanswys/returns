# frozen_string_literal: true

module Api
  module V1
    class AnalyticsController < BaseController
      # GET /api/v1/merchants/:merchant_id/analytics
      # Returns aggregated return analytics for a merchant
      def show
        merchant_id = params[:merchant_id]

        unless Merchant.exists?(merchant_id)
          return render json: { error: 'Merchant not found' }, status: :not_found
        end

        analytics = ReturnAnalyticsService.new(merchant_id).call

        render json: analytics
      end
    end
  end
end
