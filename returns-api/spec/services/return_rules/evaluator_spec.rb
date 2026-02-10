# frozen_string_literal: true

require 'rails_helper'

describe ReturnRules::Evaluator do
  describe '.call' do
    it 'accepts an order and a single rule' do
      order = double('Order')
      rule = double('ReturnRule', configuration: { 'window_days' => 30 })
      allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 10.days)
      
      decision = described_class.call(order, rule)
      expect(decision).to be_a(ReturnRules::Decision)
    end

    it 'accepts an order and an array of rules' do
      order = double('Order')
      allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 10.days)
      rules = [
        double('Rule1', configuration: { 'window_days' => 30 }),
        double('Rule2', configuration: { 'window_days' => 14 })
      ]
      
      decision = described_class.call(order, rules)
      expect(decision).to be_a(ReturnRules::Decision)
    end
  end

  describe '#call' do
    context 'with empty rules' do
      it 'returns deny decision' do
        order = double('Order')
        evaluator = described_class.new(order, [])
        decision = evaluator.call
        expect(decision.deny?).to be true
        expect(decision.reason).to eq('no_rules')
      end
    end

    context 'with single rule' do
      it 'returns the decision from that rule' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 10.days)
        rule = double('Rule', configuration: { 'window_days' => 30 })
        
        evaluator = described_class.new(order, rule)
        decision = evaluator.call
        expect(decision.approve?).to be true
      end
    end

    context 'with multiple rules - precedence' do
      it 'returns deny if any rule denies (deny has highest precedence)' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 40.days)
        allow(order).to receive(:total).and_return(50)
        
        rules = [
          double('Rule1', configuration: { 'window_days' => 30 }), # will deny (past window)
          double('Rule2', configuration: { 'price_threshold' => 100 }) # would approve (under threshold)
        ]
        
        evaluator = described_class.new(order, rules)
        decision = evaluator.call
        expect(decision.deny?).to be true
      end

      it 'returns deny if any rule denies even when others approve' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 10.days)
        allow(order).to receive(:total).and_return(150)
        
        rules = [
          double('Rule1', configuration: { 'window_days' => 30 }), # will approve (within window)
          double('Rule2', configuration: { 'price_threshold' => 100 }) # will deny (over threshold)
        ]
        
        evaluator = described_class.new(order, rules)
        decision = evaluator.call
        expect(decision.deny?).to be true
      end

      it 'returns approve when all rules approve' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 10.days)
        allow(order).to receive(:total).and_return(50)
        
        rules = [
          double('Rule1', configuration: { 'window_days' => 30 }), # will approve
          double('Rule2', configuration: { 'price_threshold' => 100 }) # will approve
        ]
        
        evaluator = described_class.new(order, rules)
        decision = evaluator.call
        expect(decision.approve?).to be true
      end
    end

    context 'with invalid configuration' do
      it 'returns deny for rule with unmatched strategy' do
        order = double('Order')
        rule = double('Rule', configuration: { 'unknown_key' => 'unknown' })
        
        evaluator = described_class.new(order, rule)
        decision = evaluator.call
        expect(decision.deny?).to be true
        expect(decision.reason).to eq('rule_denied')
      end

      it 'returns deny for rule that raises strategy error' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(nil)
        rule = double('Rule', configuration: { 'window_days' => 'not_a_number' })
        
        evaluator = described_class.new(order, rule)
        decision = evaluator.call
        expect(decision.deny?).to be true
      end
    end

    context 'with hash-based rule config (no respond_to check needed)' do
      it 'evaluates a plain hash as rule config' do
        order = double('Order')
        allow(order).to receive(:order_date).and_return(Time.zone.now.to_date - 5.days)
        
        config = { 'window_days' => 30 }
        evaluator = described_class.new(order, config)
        decision = evaluator.call
        expect(decision.approve?).to be true
      end
    end
  end
end
