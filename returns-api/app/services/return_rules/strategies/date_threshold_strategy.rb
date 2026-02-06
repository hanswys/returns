# frozen_string_literal: true

module ReturnRules
  module Strategies
    class DateThresholdStrategy
      def self.match?(config)
        config.is_a?(Hash) && config.key?('window_days')
      end

      def initialize(order, config)
        @order = order
        @config = config
      end

      def decide
        window = @config['window_days'].to_i
        order_date = extract_order_date
        return ReturnRules::Decision.new(:deny, reason: 'missing_order_date') unless order_date

        days_since = (Time.zone.now.to_date - order_date).to_i
        if days_since <= window
          ReturnRules::Decision.new(:approve, reason: 'within_window')
        else
          ReturnRules::Decision.new(:deny, reason: 'past_window')
        end
      end

      private

      def extract_order_date
        if @order.respond_to?(:order_date) && @order.order_date.present?
          @order.order_date.to_date
        elsif @order.respond_to?(:created_at)
          @order.created_at.to_date
        else
          nil
        end
      end
    end
  end
end
