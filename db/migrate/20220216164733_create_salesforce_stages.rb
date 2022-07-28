class CreateSalesforceStages < ActiveRecord::Migration[7.0]
  def change
    create_table :salesforce_stages do |t|
      t.integer :customer_id
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_index :salesforce_stages, :customer_id
  end
end
