class AddIndexToMappingTables < ActiveRecord::Migration[7.0]
  def change
    add_index :nocrm_steps, [:customer_id, :nocrm_id]
    add_index :nocrm_field_types, [:customer_id, :nocrm_id]

  end
end
