class OrderSerializer < ActiveModel::Serializer
  attributes :id, :order_number, :customer_email, :customer_name, :total_amount, :order_date, :status, :merchant_id, :created_at, :updated_at

  belongs_to :merchant
  has_many :return_requests
end
