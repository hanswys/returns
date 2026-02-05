class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.references :merchant, null: false, foreign_key: true
      t.timestamps
    end

    add_index :products, [:merchant_id, :sku], unique: true
  end
end
