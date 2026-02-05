class Product < ApplicationRecord
  belongs_to :merchant # parent 
  has_many :return_rules, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  validates :name, :sku, presence: true
  validates :sku, uniqueness: { scope: :merchant_id, message: "should be unique per merchant" } # only unique within the same merchant
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 } # price must be non-negative
end
