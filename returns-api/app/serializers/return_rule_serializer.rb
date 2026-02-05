class ReturnRuleSerializer < ActiveModel::Serializer
  attributes :id, :merchant_id, :product_id, :created_at, :updated_at, :configuration

  belongs_to :merchant
  belongs_to :product, optional: true

  # Expose configuration with flattened structure for frontend compatibility
  def configuration
    object.configuration.merge({
      'window_days' => object.window_days,
      'replacement_allowed' => object.replacement_allowed,
      'refund_allowed' => object.refund_allowed,
      'reason' => object.reason
    }).compact
  end
end
