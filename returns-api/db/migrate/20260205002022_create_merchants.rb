class CreateMerchants < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :contact_person
      t.text :address
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :merchants, :email, unique: true
    add_index :merchants, :status
  end
end
