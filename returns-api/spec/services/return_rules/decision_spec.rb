# frozen_string_literal: true

require 'rails_helper'

describe ReturnRules::Decision do
  describe 'initialization' do
    it 'initializes with status, reason, and metadata' do
      decision = described_class.new(:approve, reason: 'test', metadata: { key: 'value' })
      expect(decision.status).to eq(:approve)
      expect(decision.reason).to eq('test')
      expect(decision.metadata).to eq({ key: 'value' })
    end

    it 'coerces status to symbol' do
      decision = described_class.new('deny', reason: 'test')
      expect(decision.status).to eq(:deny)
    end
  end

  describe 'predicates' do
    it '#approve? returns true for approve status' do
      decision = described_class.new(:approve)
      expect(decision.approve?).to be true
      expect(decision.deny?).to be false
      expect(decision.green_return?).to be false
    end

    it '#deny? returns true for deny status' do
      decision = described_class.new(:deny)
      expect(decision.deny?).to be true
      expect(decision.approve?).to be false
    end

    it '#green_return? returns true for green_return status' do
      decision = described_class.new(:green_return)
      expect(decision.green_return?).to be true
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      decision = described_class.new(:approve, reason: 'test_reason', metadata: { data: 123 })
      hash = decision.to_h
      expect(hash[:status]).to eq(:approve)
      expect(hash[:reason]).to eq('test_reason')
      expect(hash[:metadata]).to eq({ data: 123 })
    end
  end
end
