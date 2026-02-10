require 'rails_helper'

RSpec.describe 'Rate Limiting', type: :request do
  before do
    Rack::Attack.enabled = true
    Rack::Attack.reset!
  end

  after do
    Rack::Attack.enabled = false
  end

  describe 'GET /api/v1/orders/lookup' do
    it 'throttles excessive requests' do
      limit = 5
      period = 60

      # Consuming the limit
      limit.times do
        get '/api/v1/orders/lookup'
      end

      # Exceeding the limit
      get '/api/v1/orders/lookup'
      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include('Rate limit exceeded')
    end
  end
end
