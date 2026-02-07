module ReturnRules
  class Evaluator
    # Evaluator applies merchant return rules (JSONB) to an Order and returns a Decision
    # Usage:
    #   decision = ReturnRules::Evaluator.call(order, merchant.return_rules)
    # or for single rule:
    #   decision = ReturnRules::Evaluator.call(order, return_rule)

    def self.call(order, rules)
      new(order, rules).call 
    end

    def initialize(order, rules)
      @order = order
      # accept a single ReturnRule, ActiveRecord::Relation, or Array
      @rules = Array.wrap(rules)
    end

    # Returns a ReturnRules::Decision
    def call
      return Decision.new(:deny, reason: 'no_rules') if @rules.blank?

      # Evaluate each rule and combine decisions with precedence: deny > approve > green_return
      decisions = @rules.map { |rule| evaluate_rule(rule) } # runs it through the strategies

      return Decision.new(:deny, reason: 'rule_denied') if decisions.any?(&:deny?)
      return Decision.new(:approve, reason: 'rule_approved') if decisions.any?(&:approve?)
      return Decision.new(:green_return, reason: 'rule_green') if decisions.any?(&:green_return?)

      Decision.new(:deny, reason: 'no_positive_rule')
    end

    private

    def evaluate_rule(rule)
      config = rule.respond_to?(:configuration) ? (rule.configuration || {}) : rule

      # Normalize keys to strings (JSONB may have symbols)
      config = config.transform_keys(&:to_s) if config.respond_to?(:transform_keys)

      strategy = select_strategy(config)
      return Decision.new(:deny, reason: 'invalid_config') unless strategy

      begin
        strategy.new(@order, config).decide
      rescue StandardError => e
        Decision.new(:deny, reason: "strategy_error: #{e.class}")
      end
    end

    def select_strategy(config)
      # Use Registry for OCP - new strategies auto-register
      Strategies::Registry.find_for(config)
    end
  end
end

