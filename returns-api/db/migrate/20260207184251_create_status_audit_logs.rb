class CreateStatusAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :status_audit_logs do |t|
      t.references :return_request, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status
      t.string :event
      t.string :triggered_by
      t.text :metadata

      t.timestamps
    end
  end
end
