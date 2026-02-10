# frozen_string_literal: true

module ReturnRules
  # Configuration value object that handles type-casting and business validation
  # for return rule configuration settings.
  #
  # @example
  #   config = ReturnRules::Configuration.new(window_days: 30, refund_allowed: true)
  #   config.valid? # => true
  #   config.to_h   # => { 'window_days' => 30, 'refund_allowed' => true, 'reason' => nil }
  #
  class Configuration
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :window_days, :integer
    attribute :refund_allowed, :boolean, default: false
    attribute :reason, :string

    # Initialize from a hash, handling both symbol and string keys
    def initialize(attributes = {})
      normalized = normalize_keys(attributes)
      super(normalized)
    end

    # Serialize to a hash with string keys (for JSONB storage)
    def to_h
      {
        'window_days' => window_days,
        'refund_allowed' => refund_allowed,
        'reason' => reason
      }.compact
    end

    alias to_hash to_h

    private

    def normalize_keys(hash)
      return {} unless hash.is_a?(Hash)

      hash.transform_keys(&:to_s).slice('window_days', 'refund_allowed', 'reason')
    end
  end
end

