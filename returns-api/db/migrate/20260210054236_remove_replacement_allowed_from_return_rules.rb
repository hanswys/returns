class RemoveReplacementAllowedFromReturnRules < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      UPDATE return_rules
      SET configuration = configuration - 'replacement_allowed'
      WHERE configuration ? 'replacement_allowed'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE return_rules
      SET configuration = configuration || '{"replacement_allowed": true}'::jsonb
      WHERE NOT (configuration ? 'replacement_allowed')
    SQL
  end
end
