class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.string :customer_email, null: false
      t.string :customer_name, null: false
      t.references :merchant, null: false, foreign_key: true
      t.decimal :total_amount, precision: 12, scale: 2, null: false
      t.datetime :order_date, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :orders, [:merchant_id, :order_number], unique: true
    add_index :orders, :customer_email
    add_index :orders, :status
  end
end
