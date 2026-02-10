require 'rails_helper'

RSpec.describe 'Api::V1::Orders', type: :request do
  let(:merchant) { create(:merchant) }
  let(:order) { create(:order, merchant: merchant, order_number: "TEST-#{SecureRandom.hex(4)}", customer_email: "test-#{SecureRandom.hex(4)}@example.com") }

  describe 'GET /api/v1/orders/lookup' do
    context 'with valid credentials' do
      it 'returns the order and a JWT token' do
        get '/api/v1/orders/lookup', params: { email: order.customer_email, order_number: order.order_number }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['order']['id']).to eq(order.id)
        expect(json['token']).to be_present
        
        decoded = JsonWebToken.decode(json['token'])
        expect(decoded[:order_id]).to eq(order.id)
        expect(decoded[:customer_email]).to eq(order.customer_email)
      end
    end

    context 'with invalid credentials' do
      it 'returns not found' do
        get '/api/v1/orders/lookup', params: { email: 'wrong@email.com', order_number: order.order_number }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
