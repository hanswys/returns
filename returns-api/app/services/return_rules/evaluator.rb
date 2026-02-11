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
      @rules = Array.wrap(rules) # loops safely over single item or array #jsonb
    end

    # Returns a ReturnRules::Decision
    def call
      return Decision.new(:deny, reason: 'no_rules') if @rules.blank?

      # Evaluate each rule — if ANY rule denies, deny the whole request
      decisions = @rules.map { |rule| evaluate_rule(rule) } # runs it through the strategies

      denied_decision = decisions.find(&:deny?)
      return denied_decision if denied_decision
      return Decision.new(:approve, reason: 'rule_approved') if decisions.any?(&:approve?)

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

