# frozen_string_literal: true

module ReturnRules
  # Custom validator for ReturnRule configuration JSON schema validation.
  #
  # Uses JSONSchemer to validate the configuration hash against a predefined schema.
  # This class follows the Single Responsibility Principle by handling only schema validation.
  #
  # @example
  #   class ReturnRule < ApplicationRecord
  #     validates_with ReturnRules::ConfigurationSchemaValidator
  #   end
  #
  class ConfigurationSchemaValidator < ActiveModel::Validator
    # JSON Schema definition — supports multiple config types via oneOf
    SCHEMA = {
      type: 'object',
      oneOf: [
        {
          properties: {
            window_days: { type: 'integer', minimum: 1 },
            refund_allowed: { type: 'boolean' },
            reason: { type: %w[string null] }
          },
          required: %w[window_days refund_allowed],
          additionalProperties: false
        },
        {
          properties: {
            price_threshold: { type: 'number', minimum: 0 },
            refund_allowed: { type: 'boolean' },
            reason: { type: %w[string null] }
          },
          required: %w[price_threshold refund_allowed],
          additionalProperties: false
        }
      ]
    }.freeze

    def validate(record)
      config = record.configuration

      validate_is_hash(record, config)
      return unless config.is_a?(Hash)

      validate_schema(record, config)
    end

    private

    def validate_is_hash(record, config)
      return if config.is_a?(Hash)

      record.errors.add(:configuration, 'must be a valid hash')
    end

    def validate_schema(record, config)
      schemer = JSONSchemer.schema(SCHEMA)
      return if schemer.valid?(config)

      errors_list = schemer.validate(config).map { |error| format_error(error) }.join(', ')
      record.errors.add(:configuration, "invalid schema: #{errors_list}")
    end

    def format_error(error)
      error['message'] || error.to_s
    end
  end
end
