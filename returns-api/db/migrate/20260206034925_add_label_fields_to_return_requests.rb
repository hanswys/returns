class AddLabelFieldsToReturnRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :return_requests, :tracking_number, :string
    add_column :return_requests, :label_url, :string
    add_column :return_requests, :carrier, :string
  end
end
