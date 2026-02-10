module Api
  module V1
    class ReturnRulesController < BaseController
      before_action :set_merchant
      before_action :set_return_rule, only: [:show, :update, :destroy]

      def index
        @return_rules = @merchant.return_rules
        render json: @return_rules, each_serializer: ReturnRuleSerializer
      end

      def show
        render json: @return_rule, serializer: ReturnRuleSerializer
      end

      def create
        @return_rule = @merchant.return_rules.new(return_rule_params)
        if @return_rule.save
          render json: @return_rule, serializer: ReturnRuleSerializer, status: :created
        else
          render json: { errors: @return_rule.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @return_rule.update(return_rule_params)
          render json: @return_rule, serializer: ReturnRuleSerializer
        else
          render json: { errors: @return_rule.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @return_rule.destroy
        head :no_content
      end

      private

      def set_merchant
        @merchant = Merchant.find(params[:merchant_id])
      end

      def set_return_rule
        @return_rule = @merchant.return_rules.find(params[:id])
      end

      def return_rule_params
        params.require(:return_rule).permit(:product_id, configuration: [:window_days, :refund_allowed, :reason])
      end
    end
  end
end
