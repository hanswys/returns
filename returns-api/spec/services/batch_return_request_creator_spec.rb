# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchReturnRequestCreator do
  let(:merchant) { create(:merchant) }
  let(:product1) { create(:product, merchant: merchant) }
  let(:product2) { create(:product, merchant: merchant) }
  let(:product3) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant, order_date: 5.days.ago) }
  let!(:return_rule) { create(:return_rule, merchant: merchant, configuration: { 'window_days' => 30, 'replacement_allowed' => true, 'refund_allowed' => true }) }

  let(:valid_params) do
    {
      order_id: order.id,
      merchant_id: merchant.id,
      reason: 'defective',
      items: [
        { product_id: product1.id },
        { product_id: product2.id }
      ]
    }
  end

  describe '.call' do
    context 'with valid params and multiple items' do
      it 'creates return requests for all items' do
        expect { described_class.call(valid_params) }.to change(ReturnRequest, :count).by(2)
      end

      it 'returns a success result with all requests' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.return_requests.size).to eq(2)
        expect(result.return_requests).to all(be_persisted)
      end

      it 'enqueues label generation for all requests' do
        expect { described_class.call(valid_params) }
          .to have_enqueued_job(GenerateShippingLabelJob).exactly(2).times
      end

      it 'applies the same reason to all items' do
        result = described_class.call(valid_params)

        expect(result.return_requests.map(&:reason)).to all(eq('defective'))
      end
    end

    context 'with item-specific notes' do
      let(:params_with_notes) do
        valid_params.merge(items: [
          { product_id: product1.id, notes: 'Screen cracked' },
          { product_id: product2.id, notes: 'Battery swollen' }
        ])
      end

      it 'appends notes to reason' do
        result = described_class.call(params_with_notes)

        expect(result.return_requests[0].reason).to eq('defective: Screen cracked')
        expect(result.return_requests[1].reason).to eq('defective: Battery swollen')
      end
    end

    context 'atomicity - when one item fails eligibility' do
      let(:old_order) { create(:order, merchant: merchant, order_date: 45.days.ago) }
      let(:mixed_params) do
        {
          order_id: old_order.id,
          merchant_id: merchant.id,
          reason: 'defective',
          items: [
            { product_id: product1.id },
            { product_id: product2.id }
          ]
        }
      end

      it 'creates no requests when eligibility fails' do
        expect { described_class.call(mixed_params) }.not_to change(ReturnRequest, :count)
      end

      it 'returns a failure result' do
        result = described_class.call(mixed_params)

        expect(result.success?).to be false
        expect(result.error_response[:error]).to be_present
      end
    end

    context 'with empty items array' do
      let(:empty_params) { valid_params.merge(items: []) }

      it 'returns a failure result' do
        result = described_class.call(empty_params)

        expect(result.success?).to be false
        expect(result.error_response[:reason]).to eq('empty_items')
      end
    end

    context 'with idempotency key' do
      let(:params_with_key) { valid_params.merge(idempotency_key: 'batch-123') }

      it 'returns existing requests on duplicate batch' do
        first_result = described_class.call(params_with_key)
        second_result = described_class.call(params_with_key)

        expect(second_result.success?).to be true
        expect(second_result.return_requests.map(&:id)).to match_array(first_result.return_requests.map(&:id))
      end

      it 'does not create duplicates' do
        described_class.call(params_with_key)

        expect { described_class.call(params_with_key) }.not_to change(ReturnRequest, :count)
      end
    end

    context 'with three items' do
      let(:three_item_params) do
        valid_params.merge(items: [
          { product_id: product1.id },
          { product_id: product2.id },
          { product_id: product3.id }
        ])
      end

      it 'creates all three requests' do
        result = described_class.call(three_item_params)

        expect(result.success?).to be true
        expect(result.return_requests.size).to eq(3)
      end
    end
  end
end
