# frozen_string_literal: true

# Clear existing data
puts 'Clearing existing data...'
ReturnRequest.destroy_all
ReturnRule.destroy_all
Order.destroy_all
Product.destroy_all
Merchant.destroy_all

puts 'Creating merchants...'
merchants = [
  {
    name: 'TechGear Pro',
    email: 'support@techgearpro.com',
    contact_person: 'Sarah Johnson',
    address: '123 Tech Boulevard, San Francisco, CA 94105'
  },
  {
    name: 'Fashion Forward',
    email: 'hello@fashionforward.com',
    contact_person: 'Michael Chen',
    address: '456 Style Avenue, New York, NY 10001'
  },
  {
    name: 'Home Essentials',
    email: 'care@homeessentials.com',
    contact_person: 'Emily Davis',
    address: '789 Living Street, Chicago, IL 60601'
  }
].map { |attrs| Merchant.create!(attrs) }

puts "Created #{merchants.count} merchants"

puts 'Creating products...'
products_data = {
  merchants[0] => [
    { name: 'Wireless Bluetooth Headphones', sku: 'TG-WBH-001', price: 79.99, description: 'Premium wireless headphones with noise cancellation' },
    { name: 'USB-C Charging Hub', sku: 'TG-UCH-002', price: 49.99, description: '7-port USB-C hub with fast charging' },
    { name: 'Mechanical Keyboard', sku: 'TG-MKB-003', price: 129.99, description: 'RGB mechanical keyboard with Cherry MX switches' },
    { name: 'Gaming Mouse', sku: 'TG-GMS-004', price: 59.99, description: 'High-precision gaming mouse with customizable buttons' },
    { name: 'Laptop Stand', sku: 'TG-LST-005', price: 39.99, description: 'Adjustable aluminum laptop stand' },
    { name: 'Pro Gaming Laptop', sku: 'TG-PGL-006', price: 1999.99, description: 'High-performance gaming laptop with RTX 4090' }
  ],
  merchants[1] => [
    { name: 'Classic Denim Jacket', sku: 'FF-CDJ-001', price: 89.99, description: 'Vintage-style denim jacket, unisex' },
    { name: 'Cotton T-Shirt Pack', sku: 'FF-CTS-002', price: 34.99, description: 'Pack of 3 premium cotton t-shirts' },
    { name: 'Leather Belt', sku: 'FF-LBT-003', price: 45.99, description: 'Genuine leather belt with silver buckle' },
    { name: 'Running Sneakers', sku: 'FF-RSN-004', price: 119.99, description: 'Lightweight running sneakers with cushioned sole' }
  ],
  merchants[2] => [
    { name: 'Ceramic Coffee Mug Set', sku: 'HE-CCM-001', price: 29.99, description: 'Set of 4 handcrafted ceramic mugs' },
    { name: 'Bamboo Cutting Board', sku: 'HE-BCB-002', price: 24.99, description: 'Eco-friendly bamboo cutting board' },
    { name: 'Stainless Steel Cookware Set', sku: 'HE-SSC-003', price: 199.99, description: '10-piece professional cookware set' },
    { name: 'Cotton Bedsheet Set', sku: 'HE-CBS-004', price: 79.99, description: 'Queen size 400-thread count sheets' },
    { name: 'LED Desk Lamp', sku: 'HE-LDL-005', price: 44.99, description: 'Adjustable LED lamp with USB charging port' }
  ]
}

products = []
products_data.each do |merchant, items|
  items.each do |attrs|
    products << Product.create!(attrs.merge(merchant: merchant))
  end
end
puts "Created #{products.count} products"

puts 'Creating orders...'
orders_data = [
  # TechGear Pro orders
  { 
    merchant: merchants[0], 
    order_number: 'TG-ORD-1001', 
    customer_email: 'john.doe@email.com', 
    customer_name: 'John Doe', 
    order_date: 80.days.ago, 
    status: :delivered,
    items: [products[0], products[1]] # Headphones + Hub
  },
  { 
    merchant: merchants[0], 
    order_number: 'TG-ORD-1002', 
    customer_email: 'jane.smith@email.com', 
    customer_name: 'Jane Smith', 
    order_date: 10.days.ago, 
    status: :delivered,
    items: [products[2], products[4]] # Keyboard + Stand
  },
  { 
    merchant: merchants[0], 
    order_number: 'TG-ORD-1003', 
    customer_email: 'bob.wilson@email.com', 
    customer_name: 'Bob Wilson', 
    order_date: 3.days.ago, 
    status: :shipped,
    items: [products[3]] # Mouse
  },
  { 
    merchant: merchants[0], 
    order_number: 'TG-ORD-1004', 
    customer_email: 'david.miller@email.com', 
    customer_name: 'David Miller', 
    order_date: 5.days.ago, 
    status: :delivered,
    items: [products[5]] # Gaming Laptop (Index 5 because new item added at end of merchant 0 list)
  },
  
  # Fashion Forward orders  
  { 
    merchant: merchants[1], 
    order_number: 'FF-ORD-2001', 
    customer_email: 'alice.jones@email.com', 
    customer_name: 'Alice Jones', 
    order_date: 7.days.ago, 
    status: :delivered,
    items: [products[5], products[6]] # Jacket + T-Shirts
  },
  { 
    merchant: merchants[1], 
    order_number: 'FF-ORD-2002', 
    customer_email: 'charlie.brown@email.com', 
    customer_name: 'Charlie Brown', 
    order_date: 15.days.ago, 
    status: :delivered,
    items: [products[8]] # Sneakers
  },
  
  # Home Essentials orders
  { 
    merchant: merchants[2], 
    order_number: 'HE-ORD-3001', 
    customer_email: 'diana.prince@email.com', 
    customer_name: 'Diana Prince', 
    order_date: 8.days.ago, 
    status: :delivered,
    items: [products[9], products[11], products[12]] # Mugs + Cookware + Sheets
  },
  { 
    merchant: merchants[2], 
    order_number: 'HE-ORD-3002', 
    customer_email: 'bruce.wayne@email.com', 
    customer_name: 'Bruce Wayne', 
    order_date: 12.days.ago, 
    status: :delivered,
    items: [products[13]] # Lamp
  }
]

orders = orders_data.map do |data|
  items = data.delete(:items)
  # Calculate total from items
  total = items.sum(&:price)
  
  order = Order.create!(data.merge(total_amount: total))
  
  items.each do |product|
    OrderItem.create!(
      order: order,
      product: product,
      quantity: 1,
      price_at_purchase: product.price
    )
  end
  order
end
puts "Created #{orders.count} orders"

puts 'Creating return rules...'
return_rules = [
  # TechGear Pro: date threshold (30 days) + price threshold ($500)
  { merchant: merchants[0], configuration: { window_days: 30, refund_allowed: true, reason: 'Standard tech returns' } },
  { merchant: merchants[0], configuration: { price_threshold: 500, refund_allowed: true, reason: 'Price limit for tech returns' } },
  # Fashion Forward: date threshold only, NO refunds (exchange only)
  { merchant: merchants[1], configuration: { window_days: 14, refund_allowed: false, reason: 'Exchange only for fashion items' } },
  # Home Essentials: generous 60-day window
  { merchant: merchants[2], configuration: { window_days: 60, refund_allowed: true, reason: 'Extended home goods warranty' } }
].map { |attrs| ReturnRule.create!(attrs) }

puts "Created #{return_rules.count} return rules"

puts 'Creating sample return requests...'
return_requests = [
  { order: orders[1], product: products[2], merchant: merchants[0], reason: 'Defective - keys stopped working', requested_date: 2.days.ago },
  { order: orders[3], product: products[6], merchant: merchants[1], reason: 'Wrong size received', requested_date: 1.day.ago }
].map { |attrs| ReturnRequest.create!(attrs) }

puts "Created #{return_requests.count} return requests"

puts ''
puts '=' * 60
puts 'SEED DATA COMPLETE!'
puts '=' * 60
puts ''
puts 'Test the Customer Portal with these credentials:'
puts ''
puts '  Email: john.doe@email.com'
puts '  Order: TG-ORD-1001'
puts ''
puts '  Email: alice.jones@email.com'
puts '  Order: FF-ORD-2001'
puts ''
puts '  Email: diana.prince@email.com'
puts '  Order: HE-ORD-3001'
puts ''
puts '  Email: david.miller@email.com'
puts '  Order: TG-ORD-1004'
puts '  (High Value Order - Should trigger Price Threshold)'
puts ''
puts '=' * 60
