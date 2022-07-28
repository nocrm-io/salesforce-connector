class CreateNocrmAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :nocrm_attributes do |t|
      t.integer :customer_id
      t.string :name
      t.string :data_type

      t.timestamps
    end
    add_index :nocrm_attributes, :customer_id
  end
end
