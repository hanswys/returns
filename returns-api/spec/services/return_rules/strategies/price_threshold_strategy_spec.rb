# frozen_string_literal: true

require 'rails_helper'

describe ReturnRules::Strategies::PriceThresholdStrategy do
  describe '.match?' do
    it 'matches when config has price_threshold key' do
      expect(described_class.match?({ 'price_threshold' => 100 })).to be true
    end

    it 'matches when config has max_order_total key' do
      expect(described_class.match?({ 'max_order_total' => 100 })).to be true
    end

    it 'does not match when config lacks both keys' do
      expect(described_class.match?({ 'other_key' => 100 })).to be false
    end

    it 'does not match non-hash config' do
      expect(described_class.match?('not a hash')).to be false
    end
  end

  describe '#decide' do
    context 'when order total is under threshold' do
      it 'returns approve decision' do
        order = double('Order', total: 50)
        strategy = described_class.new(order, { 'price_threshold' => 100 })
        decision = strategy.decide
        expect(decision.approve?).to be true
        expect(decision.reason).to eq('under_price_threshold')
      end
    end

    context 'when order total exceeds threshold' do
      it 'returns deny decision' do
        order = double('Order', total: 150)
        strategy = described_class.new(order, { 'price_threshold' => 100 })
        decision = strategy.decide
        expect(decision.deny?).to be true
        expect(decision.reason).to eq('over_price_threshold')
      end
    end

    context 'when using max_order_total key' do
      it 'applies the threshold correctly' do
        order = double('Order', total: 75)
        strategy = described_class.new(order, { 'max_order_total' => 100 })
        decision = strategy.decide
        expect(decision.approve?).to be true
      end
    end

    context 'when threshold is invalid' do
      it 'returns deny decision for zero threshold' do
        order = double('Order', total: 50)
        strategy = described_class.new(order, { 'price_threshold' => 0 })
        decision = strategy.decide
        expect(decision.deny?).to be true
      end
    end

    context 'when order has different total methods' do
      it 'uses total_amount if available' do
        order = double('Order')
        allow(order).to receive(:respond_to?).and_return(false)
        allow(order).to receive(:respond_to?).with(:total_amount).and_return(true)
        allow(order).to receive(:total_amount).and_return(60)
        strategy = described_class.new(order, { 'price_threshold' => 100 })
        decision = strategy.decide
        expect(decision.approve?).to be true
      end

      it 'uses total_cents if available' do
        order = double('Order')
        allow(order).to receive(:respond_to?).and_return(false)
        allow(order).to receive(:respond_to?).with(:total_cents).and_return(true)
        allow(order).to receive(:respond_to?).with(:currency).and_return(true)
        allow(order).to receive(:total_cents).and_return(8000) # $80
        strategy = described_class.new(order, { 'price_threshold' => 100 })
        decision = strategy.decide
        expect(decision.approve?).to be true
      end
    end

    context 'metadata' do
      it 'includes order_total and threshold in metadata' do
        order = double('Order', total: 75)
        strategy = described_class.new(order, { 'price_threshold' => 100 })
        decision = strategy.decide
        expect(decision.metadata[:order_total]).to eq(75.0)
        expect(decision.metadata[:threshold]).to eq(100.0)
      end
    end
  end
end
