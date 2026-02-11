class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :price_at_purchase, :product_id, :product_name, :product_sku, :return_status

  def product_name
    object.product.name
  end

  def product_sku
    object.product.sku
  end

  def return_status
    # Find active return request for this specific product in this order
    # Since we have a unique index on [order_id, product_id], there's at most one.
    return_request = object.order.return_requests.find { |rr| rr.product_id == object.product_id }
    return_request&.status
  end
end
