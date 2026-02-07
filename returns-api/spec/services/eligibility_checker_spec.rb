# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EligibilityChecker do
  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant, order_date: 5.days.ago) }
  let(:return_request) { build(:return_request, order: order, product: product, merchant: merchant) }

  describe '.call' do
    context 'when merchant has no return policy' do
      it 'returns ineligible result' do
        result = described_class.call(return_request)

        expect(result.eligible?).to be false
        expect(result.reason).to eq('no_return_policy')
        expect(result.details).to include('does not have a return policy')
      end
    end

    context 'when merchant has return policy' do
      let!(:return_rule) do
        create(:return_rule, merchant: merchant, configuration: {
          'window_days' => 30,
          'replacement_allowed' => true,
          'refund_allowed' => true
        })
      end

      context 'and order is within window' do
        let(:order) { create(:order, merchant: merchant, order_date: 5.days.ago) }

        it 'returns eligible result' do
          result = described_class.call(return_request)

          expect(result.eligible?).to be true
          expect(result.reason).to be_nil
        end
      end

      context 'and order is outside window' do
        let(:order) { create(:order, merchant: merchant, order_date: 45.days.ago) }

        it 'returns ineligible result' do
          result = described_class.call(return_request)

          expect(result.eligible?).to be false
          expect(result.reason).to eq('rule_denied')  # Evaluator returns this for denied rules
        end

        it 'includes detailed rejection message' do
          result = described_class.call(return_request)

          expect(result.details).to include('Return window is 30 days')
          expect(result.details).to include('days ago')
        end
      end
    end
  end

  describe 'Result struct' do
    it 'has eligible?, reason, and details attributes' do
      result = EligibilityChecker::Result.new(eligible?: true, reason: nil, details: nil)

      expect(result.eligible?).to be true
      expect(result.reason).to be_nil
      expect(result.details).to be_nil
    end
  end
end
