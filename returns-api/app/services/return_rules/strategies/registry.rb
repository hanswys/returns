# frozen_string_literal: true

module ReturnRules
  module Strategies
    # Registry for strategy classes - enables OCP (Open/Closed Principle)
    # New strategies automatically register themselves
    #
    # Usage:
    #   # Strategies auto-register when they include Registry
    #   Registry.all  # => [DateThresholdStrategy, PriceThresholdStrategy]
    #   Registry.find_for(config)  # => matching strategy class
    #
    module Registry
      class << self
        def strategies
          @strategies ||= []
        end

        # Register a strategy class
        def register(strategy_class)
          strategies << strategy_class unless strategies.include?(strategy_class)
        end

        # Get all registered strategies
        def all
          strategies
        end

        # Find strategy that matches the given config
        # Note: Explicitly reference strategies to ensure they're loaded (Rails autoloading)
        def find_for(config)
          ensure_strategies_loaded
          strategies.find { |s| s.match?(config) }
        end

        # Clear registry (useful for testing)
        def reset!
          @strategies = []
          @strategies_loaded = false
        end

        private

        # Force-load strategy classes so they can self-register
        def ensure_strategies_loaded
          return if @strategies_loaded

          # Reference each strategy class to trigger autoload and registration
          DateThresholdStrategy
          PriceThresholdStrategy
          @strategies_loaded = true
        end

      end

      # When included in a strategy, auto-register it
      def self.included(base)
        Registry.register(base)
      end
    end
  end
end
