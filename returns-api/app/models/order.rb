class Order < ApplicationRecord
  belongs_to :merchant
  has_many :return_requests, dependent: :destroy

  validates :order_number, presence: true, uniqueness: { scope: :merchant_id }
  validates :customer_email, :customer_name, :total_amount, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :order_date, presence: true

  enum :status, { pending: 0, confirmed: 1, shipped: 2, delivered: 3, cancelled: 4 }
end
