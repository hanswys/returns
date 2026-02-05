class ReturnRuleSerializer < ActiveModel::Serializer
  attributes :id, :window_days, :reason, :replacement_allowed, :refund_allowed, :merchant_id, :product_id, :created_at, :updated_at

  belongs_to :merchant
  belongs_to :product, optional: true
end
