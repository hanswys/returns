# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnRules::Strategies::Registry do
  before do
    # Reset registry before each test
    described_class.reset!
  end

  describe '.register' do
    it 'adds strategy to registry' do
      mock_strategy = Class.new
      described_class.register(mock_strategy)

      expect(described_class.all).to include(mock_strategy)
    end

    it 'does not add duplicate strategies' do
      mock_strategy = Class.new
      described_class.register(mock_strategy)
      described_class.register(mock_strategy)

      expect(described_class.all.count { |s| s == mock_strategy }).to eq(1)
    end
  end

  describe '.all' do
    it 'returns all registered strategies' do
      strategy1 = Class.new
      strategy2 = Class.new
      described_class.register(strategy1)
      described_class.register(strategy2)

      expect(described_class.all).to contain_exactly(strategy1, strategy2)
    end
  end

  describe '.find_for' do
    it 'finds strategy that matches config' do
      matching_strategy = Class.new do
        def self.match?(config)
          config['special_key'].present?
        end
      end
      described_class.register(matching_strategy)

      result = described_class.find_for({ 'special_key' => 'value' })
      expect(result).to eq(matching_strategy)
    end

    it 'returns nil when no strategy matches' do
      result = described_class.find_for({ 'unknown_key' => 'value' })
      expect(result).to be_nil
    end
  end

  describe '.reset!' do
    it 'clears all registered strategies' do
      described_class.register(Class.new)
      described_class.reset!

      expect(described_class.all).to be_empty
    end
  end

  describe 'auto-registration via include' do
    it 'automatically registers class when Registry is included' do
      described_class.reset!

      new_strategy = Class.new do
        include ReturnRules::Strategies::Registry
      end

      expect(described_class.all).to include(new_strategy)
    end
  end
end
