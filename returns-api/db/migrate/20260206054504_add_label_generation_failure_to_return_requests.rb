class AddLabelGenerationFailureToReturnRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :return_requests, :label_generation_failed_at, :datetime
    add_column :return_requests, :label_generation_error, :text
  end
end
