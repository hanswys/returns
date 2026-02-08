# frozen_string_literal: true

# Service object for checking return request eligibility
# Extracted from ReturnRequestCreator for SRP compliance
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
    return ineligible('no_return_policy', 'This merchant does not have a return policy configured') unless return_rule

    decision = return_rule.eligible?(@order) # decision object (status, reason, metadata)

    if decision.status == :approve
      Result.new(eligible?: true)
    else
      ineligible(
        decision.reason || 'not_eligible',
        build_rejection_details
      )
    end
  end

  private

  def return_rule
    @return_rule ||= ReturnRule.find_by(merchant_id: @merchant&.id)
  end

  def ineligible(reason, details)
    Result.new(eligible?: false, reason: reason, details: details)
  end

  def build_rejection_details
    return 'Return policy check failed' unless @order && return_rule

    window_days = return_rule.configuration['window_days']
    return 'Return policy configuration missing' unless window_days

    order_date = @order.order_date.to_date
    deadline = order_date + window_days.days
    days_since = (Date.current - order_date).to_i

    "Return window is #{window_days} days. Order was placed #{days_since} days ago " \
      "(#{order_date.strftime('%B %d, %Y')}). Return deadline was #{deadline.strftime('%B %d, %Y')}."
  end
end
