class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price_at_purchase, :product_id, :product_name, :product_sku

  def product_name
    object.product.name
  end

  def product_sku
    object.product.sku
  end
end
