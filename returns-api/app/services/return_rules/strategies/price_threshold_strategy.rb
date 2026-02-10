# frozen_string_literal: true

module ReturnRules
  module Strategies
    class PriceThresholdStrategy
      include Registry  # Auto-registers this strategy

      # Matches when configuration defines a price threshold (key: 'price_threshold' or 'max_order_total')
      def self.match?(config)
        config.is_a?(Hash) && (config.key?('price_threshold') || config.key?('max_order_total'))
      end

      def initialize(order, config)
        @order = order
        @config = config
      end

      def decide
        threshold = (@config['price_threshold'] || @config['max_order_total']).to_f
        return ReturnRules::Decision.new(:deny, reason: 'invalid_threshold') if threshold <= 0

        total = extract_order_total.to_f
        if total <= threshold
          ReturnRules::Decision.new(:approve, reason: 'under_price_threshold', metadata: { order_total: total, threshold: threshold })
        else
          ReturnRules::Decision.new(:deny, reason: 'over_price_threshold', metadata: { order_total: total, threshold: threshold })
        end
      end

      private

      def extract_order_total
        if @order.respond_to?(:total)
          @order.total
        elsif @order.respond_to?(:total_amount)
          @order.total_amount
        elsif @order.respond_to?(:total_cents) && @order.respond_to?(:currency)
          @order.total_cents.to_f / 100.0
        else
          0
        end
      end
    end
  end
end
