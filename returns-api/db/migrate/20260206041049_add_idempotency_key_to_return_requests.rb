class AddIdempotencyKeyToReturnRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :return_requests, :idempotency_key, :string
    add_index :return_requests, :idempotency_key, unique: true
  end
end
