class CreateNocrmSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :nocrm_steps do |t|
      t.integer :customer_id
      t.integer :nocrm_id
      t.string :name
      t.string :pipeline_name
      t.integer :pipeline_id
      t.integer :position

      t.timestamps
    end
    add_index :nocrm_steps, :customer_id
  end
end
