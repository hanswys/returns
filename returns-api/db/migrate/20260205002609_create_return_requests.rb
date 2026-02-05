class CreateReturnRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :return_requests do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.text :reason, null: false
      t.datetime :requested_date, null: false
      t.integer :status, default: 0, null: false
      t.references :merchant, null: false, foreign_key: true
      t.timestamps
    end

    add_index :return_requests, [:order_id, :product_id], unique: true
    add_index :return_requests, :status
  end
end
