# frozen_string_literal: true

require 'rails_helper'

describe ReturnRule do
  describe 'store_accessor - configuration JSONB' do
    let(:merchant) { create(:merchant) }

    it 'stores and retrieves window_days from configuration JSONB' do
      rule = create(:return_rule, merchant:, configuration: { window_days: 30, replacement_allowed: true, refund_allowed: false })
      expect(rule.window_days).to eq(30)
    end

    it 'stores and retrieves replacement_allowed from configuration JSONB' do
      rule = create(:return_rule, merchant:, configuration: { window_days: 30, replacement_allowed: true, refund_allowed: false })
      expect(rule.replacement_allowed).to be true
    end

    it 'stores and retrieves refund_allowed from configuration JSONB' do
      rule = create(:return_rule, merchant:, configuration: { window_days: 30, replacement_allowed: false, refund_allowed: true })
      expect(rule.refund_allowed).to be true
    end

    it 'stores multiple fields in configuration JSONB' do
      rule = create(:return_rule, merchant:, configuration: {
        window_days: 30,
        replacement_allowed: true,
        refund_allowed: true,
        reason: 'defect'
      })
      expect(rule.window_days).to eq(30)
      expect(rule.replacement_allowed).to be true
      expect(rule.refund_allowed).to be true
      expect(rule.configuration['reason']).to eq('defect')
    end
  end

  describe 'JSON Schema validation' do
    let(:merchant) { create(:merchant) }

    it 'validates valid configuration' do
      rule = build(:return_rule, merchant:, configuration: { window_days: 30, replacement_allowed: true, refund_allowed: false })
      expect(rule.valid?).to be true
    end

    it 'rejects invalid configuration with missing required fields' do
      rule = build(:return_rule, merchant:, configuration: { window_days: 30 })
      expect(rule.valid?).to be false
      expect(rule.errors[:configuration]).to be_present
    end

    it 'rejects invalid window_days type' do
      rule = build(:return_rule, merchant:, configuration: { window_days: 'thirty', replacement_allowed: true, refund_allowed: false })
      expect(rule.valid?).to be false
    end

    it 'validates configuration with all optional fields' do
      rule = build(:return_rule, merchant:, configuration: {
        window_days: 30,
        replacement_allowed: true,
        refund_allowed: false
      })
      expect(rule.valid?).to be true
    end
  end

  describe '#eligible?' do
    let(:merchant) { create(:merchant) }
    let(:rule) { create(:return_rule, merchant:, configuration: { window_days: 30 }) }
    let(:order) { create(:order, merchant:, order_date: 10.days.ago) }

    it 'delegates to ReturnRules::Evaluator' do
      decision = rule.eligible?(order)
      expect(decision).to be_a(ReturnRules::Decision)
    end

    it 'returns approve decision for recent order within window' do
      decision = rule.eligible?(order)
      expect(decision.approve?).to be true
    end

    it 'returns deny decision for order past window' do
      old_order = create(:order, merchant:, order_date: 40.days.ago)
      decision = rule.eligible?(old_order)
      expect(decision.deny?).to be true
    end
  end

  describe 'factory' do
    it 'creates a valid return rule' do
      rule = create(:return_rule)
      expect(rule).to be_persisted
      expect(rule.configuration).to be_present
      expect(rule.window_days).to be_present
    end
  end
end
