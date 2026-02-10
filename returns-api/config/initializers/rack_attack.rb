# frozen_string_literal: true

# Rate limiting and request throttling
# See: https://github.com/rack/rack-attack
#
class Rack::Attack
  # Cache store for rate limiting
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # === Throttle Rules ===

  # Rate limit order lookup: 5 requests per minute per IP
  throttle('orders/lookup', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/api/v1/orders/lookup' && req.get?
  end

  # Rate limit return request creation: 10 requests per minute per IP
  throttle('return_requests/create', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/api/v1/return_requests' && req.post?
  end

  # General API rate limit: 100 requests per minute per IP
  throttle('req/ip', limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Stricter limit for batch operations: 10 per minute
  throttle('batch/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path.include?('/batch') && req.post?
  end

  # Stricter limit for state-changing operations: 30 per minute
  throttle('mutations/ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/') && (req.patch? || req.post? || req.delete?)
  end

  # === Blocklist ===

  # Block suspicious requests (SQL injection attempts, etc.)
  blocklist('block/suspicious') do |req|
    # Block if request contains obvious SQL injection patterns
    suspicious = req.query_string&.match?(/(\-\-|;|DROP|DELETE|UPDATE|INSERT)/i)
    suspicious || req.path&.include?('..')
  end

  # === Response Configuration ===

  # Custom throttled response
  self.throttled_responder = lambda do |req|
    retry_after = (req.env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{ error: 'Rate limit exceeded. Please try again later.', retry_after: retry_after }.to_json]
    ]
  end
end
