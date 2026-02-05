module ReturnRules
  class Evaluator
    # Evaluates if a given order is eligible for return based on a rule's configuration
    # @param order [Order] the order to evaluate
    # @param configuration [Hash] the rule configuration from JSONB
    # @return [Boolean] true if order is eligible, false otherwise

    def self.call(order, configuration)
      new(order, configuration).evaluate
    end

    def initialize(order, configuration)
      @order = order
      @configuration = configuration
    end

    def evaluate
      return false if @configuration.blank?

      # Validate configuration has required fields
      return false unless has_required_fields?

      # Check if order is within return window
      return false unless within_return_window?

      # Check if at least one return option is enabled
      return false unless has_return_option?

      true
    end

    private

    def has_required_fields?
      window_days = @configuration['window_days']
      
      # Validate window_days exists and is a valid positive integer
      return false unless window_days.present?
      return false unless window_days.is_a?(Integer) || window_days.to_s.match?(/^\d+$/)
      
      window_days.to_i > 0
    end

    def within_return_window?
      window_days = @configuration['window_days'].to_i
      order_date = @order.order_date
      days_since_order = (Time.zone.now.to_date - order_date).to_i
      
      days_since_order <= window_days
    end

    def has_return_option?
      replacement_allowed = @configuration['replacement_allowed']
      refund_allowed = @configuration['refund_allowed']

      # Validate boolean values
      replacement_allowed = ActiveModel::Type::Boolean.new.cast(replacement_allowed) if replacement_allowed.is_a?(String)
      refund_allowed = ActiveModel::Type::Boolean.new.cast(refund_allowed) if refund_allowed.is_a?(String)

      replacement_allowed.present? || refund_allowed.present?
    end
  end
end
