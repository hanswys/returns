# frozen_string_literal: true

class AddCompositeIndexToReturnRequests < ActiveRecord::Migration[8.0]
  def change
    # Composite index for merchant dashboard queries
    # Covers: WHERE merchant_id = ? AND status = ? ORDER BY created_at DESC
    add_index :return_requests, [:merchant_id, :status, :created_at],
              name: 'index_return_requests_on_merchant_status_created',
              if_not_exists: true
  end
end
