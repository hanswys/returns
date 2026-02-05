# frozen_string_literal: true

require 'rails_helper'

describe ReturnRules::Strategies::DateThresholdStrategy do
  let(:config) { { 'window_days' => 30 } }
  let(:order) { double('Order', order_date: Time.zone.now.to_date - 10.days) }

  describe '.match?' do
    it 'matches when config has window_days key' do
      expect(described_class.match?({ 'window_days' => 30 })).to be true
    end

    it 'does not match when config lacks window_days key' do
      expect(described_class.match?({ 'other_key' => 30 })).to be false
    end

    it 'does not match non-hash config' do
      expect(described_class.match?('not a hash')).to be false
    end
  end

  describe '#decide' do
    context 'when order is within return window' do
      it 'returns approve decision' do
        order = double('Order', order_date: Time.zone.now.to_date - 10.days)
        strategy = described_class.new(order, { 'window_days' => 30 })
        decision = strategy.decide
        expect(decision.approve?).to be true
        expect(decision.reason).to eq('within_window')
      end
    end

    context 'when order is past return window' do
      it 'returns deny decision' do
        order = double('Order', order_date: Time.zone.now.to_date - 40.days)
        strategy = described_class.new(order, { 'window_days' => 30 })
        decision = strategy.decide
        expect(decision.deny?).to be true
        expect(decision.reason).to eq('past_window')
      end
    end

    context 'when order date is missing' do
      it 'returns deny decision' do
        order = double('Order')
        allow(order).to receive(:respond_to?).and_return(false)
        strategy = described_class.new(order, { 'window_days' => 30 })
        decision = strategy.decide
        expect(decision.deny?).to be true
        expect(decision.reason).to eq('missing_order_date')
      end
    end

    context 'when order has created_at instead of order_date' do
      it 'uses created_at to determine days since order' do
        order = double('Order', created_at: Time.zone.now - 15.days)
        allow(order).to receive(:respond_to?).with(:order_date).and_return(false)
        allow(order).to receive(:respond_to?).with(:created_at).and_return(true)
        strategy = described_class.new(order, { 'window_days' => 30 })
        decision = strategy.decide
        expect(decision.approve?).to be true
      end
    end
  end
end
