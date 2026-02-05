class ReturnRule < ApplicationRecord
  belongs_to :merchant
  belongs_to :product, optional: true

  # Store accessor for JSONB configuration fields
  store_accessor :configuration, :window_days, :replacement_allowed, :refund_allowed, :reason

  validates :merchant_id, presence: true
  validate :configuration_valid
  validate :configuration_schema_valid
  validate :at_least_one_option_enabled

  # JSON Schema definition for configuration validation
  CONFIGURATION_SCHEMA = {
    type: 'object',
    properties: {
      window_days: { type: 'integer', minimum: 1 },
      replacement_allowed: { type: 'boolean' },
      refund_allowed: { type: 'boolean' },
      reason: { type: ['string', 'null'] }
    },
    required: ['window_days', 'replacement_allowed', 'refund_allowed'],
    additionalProperties: false
  }.freeze

  def initialize(attributes = {})
    # Ensure configuration defaults to empty hash
    super
    self.configuration ||= {}
  end

  # Type casting for configuration values from forms/API
  def window_days=(value)
    super(value.to_i) if value.present?
  end

  def replacement_allowed=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  def refund_allowed=(value)
    super(ActiveModel::Type::Boolean.new.cast(value))
  end

  # Evaluate if an order is eligible for return under this rule
  def eligible?(order)
    ReturnRules::Evaluator.call(order, configuration)
  end

  private

  def configuration_valid
    unless configuration.is_a?(Hash)
      errors.add(:configuration, 'must be a valid hash')
    end
  end

  def configuration_schema_valid
    return if configuration.blank? || !configuration.is_a?(Hash)

    schemer = JSONSchemer.schema(CONFIGURATION_SCHEMA)
    unless schemer.valid?(configuration)
      errors_list = schemer.validate(configuration).map { |error| error['message'] || error.to_s }.join(', ')
      errors.add(:configuration, "invalid schema: #{errors_list}")
    end
  end

  def at_least_one_option_enabled
    return if configuration.blank?

    replacement = ActiveModel::Type::Boolean.new.cast(configuration['replacement_allowed'])
    refund = ActiveModel::Type::Boolean.new.cast(configuration['refund_allowed'])

    unless replacement || refund
      errors.add(:base, 'At least one of replacement_allowed or refund_allowed must be true')
    end
  end
end
