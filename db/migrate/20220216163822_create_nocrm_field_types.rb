class CreateNocrmFieldTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :nocrm_field_types do |t|
      t.integer :customer_id
      t.integer :nocrm_id
      t.string :field_type
      t.string :parent_type
      t.string :name

      t.timestamps
    end
    add_index :nocrm_field_types, :customer_id
  end
end
