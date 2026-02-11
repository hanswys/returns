require 'rails_helper'

RSpec.describe 'Api::V1::ReturnRequests', type: :request do
  let(:merchant) { create(:merchant) }
  let(:product) { create(:product, merchant: merchant) }
  let(:order) { create(:order, merchant: merchant) }
  let!(:return_rule) { create(:return_rule, merchant: merchant, configuration: { window_days: 30, refund_allowed: true }) }
  
  # Valid token for the order
  let(:token) { JsonWebToken.encode(order_id: order.id, customer_email: order.customer_email) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST /api/v1/return_requests' do
    let(:valid_params) do
      {
        return_request: {
          order_id: order.id,
          product_id: product.id,
          merchant_id: merchant.id,
          reason: 'defective',
          requested_date: Date.today
        }
      }
    end

    context 'with valid token' do
      it 'creates a return request' do
        post '/api/v1/return_requests', params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        post '/api/v1/return_requests', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with token for different order' do
      let(:other_order) { create(:order, merchant: merchant) }
      let(:other_token) { JsonWebToken.encode(order_id: other_order.id, customer_email: other_order.customer_email) }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_token}" } }

      it 'returns forbidden' do
        post '/api/v1/return_requests', params: valid_params, headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/return_requests/:id' do
    let(:return_request) { create(:return_request, order: order, merchant: merchant, product: product) }

    context 'with valid token' do
      it 'returns the return request' do
        get "/api/v1/return_requests/#{return_request.id}", headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with token for different order' do
      let(:other_order) { create(:order, merchant: merchant) }
      let(:other_token) { JsonWebToken.encode(order_id: other_order.id, customer_email: other_order.customer_email) }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_token}" } }

      it 'returns forbidden' do
        get "/api/v1/return_requests/#{return_request.id}", headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/return_requests/batch' do
    let(:batch_params) do
      {
        order_id: order.id,
        merchant_id: merchant.id,
        reason: 'defective',
        items: [
          { product_id: product.id, notes: 'Broken' }
        ]
      }
    end

    context 'with valid token' do
      it 'creates return requests' do
        post '/api/v1/return_requests/batch', params: batch_params, headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        post '/api/v1/return_requests/batch', params: batch_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
