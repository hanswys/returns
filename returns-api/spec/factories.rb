# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    order
    product { association :product, merchant: order.merchant }
    quantity { 1 }
    price_at_purchase { product.price }
  end

  factory :status_audit_log do
    return_request { nil }
    from_status { "MyString" }
    to_status { "MyString" }
    event { "MyString" }
    triggered_by { "MyString" }
    metadata { "MyText" }
  end

  factory :merchant do
    sequence(:name) { |n| "Merchant #{n}" }
    sequence(:email) { |n| "merchant#{SecureRandom.hex(4)}@example.com" }
    contact_person { 'John Doe' }
  end

  factory :order do
    merchant
    sequence(:order_number) { |n| "ORD#{n}" }
    order_date { 10.days.ago.to_date }
    total_amount { 99.99 }
    customer_name { 'Jane Smith' }
    customer_email { 'jane@example.com' }
  end

  factory :product do
    merchant
    name { 'Test Product' }
    sequence(:sku) { |n| "SKU#{n}" }
    price { 49.99 }
  end

  factory :return_request do
    order
    product
    merchant { order.merchant }
    reason { 'defect' }
    requested_date { 5.days.ago.to_date }
  end

  factory :return_rule do
    merchant
    configuration do
      {
        window_days: 30,
        refund_allowed: true
      }
    end
  end
end
