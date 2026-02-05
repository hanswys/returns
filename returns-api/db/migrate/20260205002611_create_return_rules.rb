class CreateReturnRules < ActiveRecord::Migration[8.1]
  def change
    create_table :return_rules do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.integer :window_days, null: false
      t.string :reason
      t.boolean :replacement_allowed, default: true, null: false
      t.boolean :refund_allowed, default: true, null: false
      t.timestamps
    end

    add_index :return_rules, [:merchant_id, :product_id], unique: true
  end
end
