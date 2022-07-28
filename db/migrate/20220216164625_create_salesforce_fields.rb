class CreateSalesforceFields < ActiveRecord::Migration[7.0]
  def change
    create_table :salesforce_fields do |t|
      t.integer :customer_id
      t.string :name
      t.string :label
      t.string :object_type
      t.boolean :is_required

      t.timestamps
    end
    add_index :salesforce_fields, :customer_id
  end
end
