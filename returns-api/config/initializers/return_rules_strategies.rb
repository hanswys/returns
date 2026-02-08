# frozen_string_literal: true

# Eager-load return rule strategies so they can self-register with the Registry.
# This follows the Open/Closed Principle - new strategies are automatically
# discovered without modifying existing code.
#
# Each strategy class includes ReturnRules::Strategies::Registry, which
# triggers auto-registration when the class is loaded.
#
Rails.application.config.to_prepare do
  strategies_path = Rails.root.join('app/services/return_rules/strategies')

  Dir[strategies_path.join('*.rb')].each do |file|
    # Skip the registry itself
    next if file.end_with?('registry.rb')

    require_dependency file
  end
end
