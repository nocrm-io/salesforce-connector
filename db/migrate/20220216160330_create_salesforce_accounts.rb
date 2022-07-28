class CreateSalesforceAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :salesforce_accounts do |t|
      t.integer :customer_id
      t.string :access_token
      t.string :refresh_token
      t.string :domain

      t.timestamps
    end

    add_index :salesforce_accounts, :customer_id
  end
end
