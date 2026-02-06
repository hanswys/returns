class ReturnRequestSerializer < ActiveModel::Serializer
  attributes :id, :reason, :requested_date, :status, :order_id, :product_id, :merchant_id,
             :tracking_number, :label_url, :carrier, :created_at, :updated_at

  belongs_to :order
  belongs_to :product
  belongs_to :merchant
end
