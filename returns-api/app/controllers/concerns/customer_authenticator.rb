# frozen_string_literal: true

module CustomerAuthenticator
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_customer!
  end

  private

  def authenticate_customer!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:order_id] && decoded[:customer_email]
      Current.actor = "customer:#{decoded[:customer_email]}"
      @current_customer_context = Struct.new(:order_id, :customer_email).new(
        decoded[:order_id],
        decoded[:customer_email]
      )
    else
      render json: { error: 'Unauthorized access' }, status: :unauthorized
    end
  end

  def current_customer_context
    @current_customer_context
  end
end
