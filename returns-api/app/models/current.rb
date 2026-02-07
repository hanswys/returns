# frozen_string_literal: true

# Thread-safe storage for request-scoped attributes
# Used to track the actor (user/system) triggering state changes
#
# Example:
#   Current.actor = "admin:123"
#   Current.actor = "webhook:carrier"
#   Current.actor = "system"
#
class Current < ActiveSupport::CurrentAttributes
  attribute :actor  # Who triggered the action (e.g., "system", "admin:123", "webhook:carrier")
end
