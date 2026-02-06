# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnRequestCreator do
  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant, order_date: 5.days.ago) }
  let!(:return_rule) { create(:return_rule, merchant: merchant, configuration: { 'window_days' => 30, 'replacement_allowed' => true, 'refund_allowed' => true }) }

  let(:valid_params) do
    {
      order_id: order.id,
      product_id: product.id,
      merchant_id: merchant.id,
      reason: 'Defective product',
      requested_date: Date.current
    }
  end

  describe '.call' do
    context 'with valid params within return window' do
      it 'creates a return request' do
        expect { described_class.call(valid_params) }.to change(ReturnRequest, :count).by(1)
      end

      it 'returns a success result' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.return_request).to be_persisted
        expect(result.status_code).to eq(:created)
      end

      it 'enqueues a shipping label job' do
        expect { described_class.call(valid_params) }
          .to have_enqueued_job(GenerateShippingLabelJob)
      end
    end

    context 'with idempotency key' do
      let(:params_with_key) { valid_params.merge(idempotency_key: 'unique-key-123') }

      it 'returns existing request on duplicate key' do
        first_result = described_class.call(params_with_key)
        second_result = described_class.call(params_with_key)

        expect(second_result.success?).to be true
        expect(second_result.return_request.id).to eq(first_result.return_request.id)
        expect(second_result.status_code).to eq(:ok)
      end

      it 'does not create duplicate requests' do
        described_class.call(params_with_key)

        expect { described_class.call(params_with_key) }.not_to change(ReturnRequest, :count)
      end
    end

    context 'when order is past return window' do
      let(:order) { create(:order, merchant: merchant, order_date: 45.days.ago) }

      it 'returns a failure result' do
        result = described_class.call(valid_params)

        expect(result.success?).to be false
        expect(result.error_response[:error]).to eq('Return not allowed')
        expect(result.error_response[:reason]).to be_present
      end
    end

    context 'when merchant has no return policy' do
      before { ReturnRule.destroy_all }

      it 'returns a failure result' do
        result = described_class.call(valid_params)

        expect(result.success?).to be false
        expect(result.error_response[:reason]).to eq('no_return_policy')
      end
    end
  end
end
