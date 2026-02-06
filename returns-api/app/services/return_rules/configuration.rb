# frozen_string_literal: true

module ReturnRules
  # Configuration value object that handles type-casting and business validation
  # for return rule configuration settings.
  #
  # This class encapsulates the configuration attributes and validates that
  # at least one return option (replacement or refund) is enabled.
  #
  # @example
  #   config = ReturnRules::Configuration.new(window_days: 30, replacement_allowed: true, refund_allowed: false)
  #   config.valid? # => true
  #   config.to_h   # => { 'window_days' => 30, 'replacement_allowed' => true, 'refund_allowed' => false, 'reason' => nil }
  #
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :window_days, :integer
    attribute :replacement_allowed, :boolean, default: false
    attribute :refund_allowed, :boolean, default: false
    attribute :reason, :string

    validate :at_least_one_option_enabled

    # Initialize from a hash, handling both symbol and string keys
    def initialize(attributes = {})
      normalized = normalize_keys(attributes)
      super(normalized)
    end

    # Serialize to a hash with string keys (for JSONB storage)
    def to_h
      {
        'window_days' => window_days,
        'replacement_allowed' => replacement_allowed,
        'refund_allowed' => refund_allowed,
        'reason' => reason
      }.compact
    end

    alias to_hash to_h

    private

    def normalize_keys(hash)
      return {} unless hash.is_a?(Hash)

      hash.transform_keys(&:to_s).slice('window_days', 'replacement_allowed', 'refund_allowed', 'reason')
    end

    def at_least_one_option_enabled
      return if replacement_allowed || refund_allowed

      errors.add(:base, 'At least one of replacement_allowed or refund_allowed must be true')
    end
  end
end
