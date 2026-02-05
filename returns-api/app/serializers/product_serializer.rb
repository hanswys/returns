class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :sku, :description, :price, :merchant_id, :created_at, :updated_at

  belongs_to :merchant
end
