# frozen_string_literal: true

class ReturnRule < ApplicationRecord
  belongs_to :merchant
  belongs_to :product, optional: true

  # Store accessor for JSONB configuration fields (accesses them as attributes)
  # First value must be db jsonb
  store_accessor :configuration, :window_days, :refund_allowed, :reason

  # Validations
  validates :merchant_id, presence: true
  validates_with ReturnRules::ConfigurationSchemaValidator # must have a validate method
  validate :configuration_business_rules

  def initialize(attributes = {})
    super # sets up db conn
    self.configuration ||= {}
  end

  # Type casting for configuration values from forms/API
  # Delegated to Configuration value object for consistency
  def window_days=(value)
    super(value.present? ? value.to_i : nil)
  end


  def refund_allowed=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  # Evaluate if an order is eligible for return under this rule
  def eligible?(order)
    ReturnRules::Evaluator.call(order, configuration)
  end

  # Build a Configuration value object from current configuration
  def configuration_object
    ReturnRules::Configuration.new(configuration)
  end

  private

  def configuration_business_rules
    return if configuration.blank?

    config_obj = configuration_object
    return if config_obj.valid?

    config_obj.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end
