class RefactorReturnRulesToJsonb < ActiveRecord::Migration[8.1]
  def change
    # Step 1: Add new JSONB configuration column
    add_column :return_rules, :configuration, :jsonb, default: {}, null: false

    # Step 2: Add GIN index for performance
    add_index :return_rules, :configuration, using: :gin

    # Step 3: Migrate existing data
    reversible do |dir|
      dir.up do
        # Migrate data from scalar columns to JSONB
        execute <<-SQL
          UPDATE return_rules
          SET configuration = jsonb_build_object(
            'window_days', window_days,
            'replacement_allowed', replacement_allowed,
            'refund_allowed', refund_allowed,
            'reason', reason
          )
          WHERE window_days IS NOT NULL
        SQL
      end

      dir.down do
        # Restore data from JSONB back to scalar columns (for rollback)
        execute <<-SQL
          UPDATE return_rules
          SET 
            window_days = COALESCE((configuration->>'window_days')::integer, 0),
            replacement_allowed = COALESCE((configuration->>'replacement_allowed')::boolean, true),
            refund_allowed = COALESCE((configuration->>'refund_allowed')::boolean, true),
            reason = configuration->>'reason'
          WHERE configuration IS NOT NULL
        SQL
      end
    end

    # Step 4: Drop old columns (after data migration)
    remove_column :return_rules, :window_days, :integer
    remove_column :return_rules, :replacement_allowed, :boolean
    remove_column :return_rules, :refund_allowed, :boolean
    remove_column :return_rules, :reason, :string
  end
end
