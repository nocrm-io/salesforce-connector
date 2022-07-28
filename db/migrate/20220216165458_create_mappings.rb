class CreateMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :mappings do |t|
      t.integer :customer_id
      t.integer :nocrm_object_id
      t.string :nocrm_object_type
      t.integer :salesforce_object_id
      t.string :salesforce_object_type

      t.timestamps
    end
    add_index :mappings, :customer_id
  end
end
