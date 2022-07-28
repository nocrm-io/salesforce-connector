class AddWebhooksTokenToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :webhooks_token, :string
    add_index :customers, :webhooks_token, unique: true
  end
end
