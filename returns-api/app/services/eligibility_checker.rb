# frozen_string_literal: true

# Service object for checking return request eligibility
# Supports multiple return rules per merchant.
# Enforces refund_allowed after strategy evaluation.
#
# Usage:
#   result = EligibilityChecker.call(return_request)
#   if result.eligible?
#     # proceed
#   else
#     result.reason  # => 'past_window'
#     result.details # => 'Return window is 30 days...'
#   end
#
class EligibilityChecker
  Result = Struct.new(:eligible?, :reason, :details, keyword_init: true)

  def self.call(return_request)
    new(return_request).call
  end

  def initialize(return_request)
    @return_request = return_request
    @order = return_request.order
    @merchant = return_request.merchant
  end

  def call
    return ineligible('no_return_policy', 'This merchant does not have a return policy configured') unless return_rules.any?

    # Step 1: Run all rules through the Evaluator (deny wins)
    decision = ReturnRules::Evaluator.call(@order, return_rules)

    unless decision.approve?
      return ineligible(
        decision.reason || 'not_eligible',
        build_rejection_details(decision)
      )
    end

    # Step 2: Enforce refund_allowed — if ANY rule disallows refunds, deny
    unless refund_allowed?
      return ineligible('refund_not_allowed', 'This merchant does not accept refund returns')
    end

    Result.new(eligible?: true)
  end

  private

  def return_rules
    @return_rules ||= ReturnRule.where(merchant_id: @merchant&.id)
  end

  def refund_allowed?
    return_rules.all? { |rule| rule.configuration&.dig('refund_allowed') != false }
  end

  def ineligible(reason, details)
    Result.new(eligible?: false, reason: reason, details: details)
  end

  def build_rejection_details(decision)
    return 'Return policy check failed' unless @order && return_rules.any?

    # Use the first rule with window_days for the detail message
    rule_with_window = return_rules.find { |r| r.configuration&.key?('window_days') }
    return "Return policy check failed: #{decision.reason}" unless rule_with_window

    window_days = rule_with_window.configuration['window_days']
    return "Return policy check failed: #{decision.reason}" unless window_days

    order_date = @order.order_date.to_date
    deadline = order_date + window_days.days
    days_since = (Date.current - order_date).to_i

    "Return window is #{window_days} days. Order was placed #{days_since} days ago " \
      "(#{order_date.strftime('%B %d, %Y')}). Return deadline was #{deadline.strftime('%B %d, %Y')}."
  end
end

