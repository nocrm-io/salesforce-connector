class CreateNocrmWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :nocrm_webhooks do |t|
      t.integer :customer_id
      t.integer :nocrm_id
      t.string :event

      t.timestamps
    end

    add_index :nocrm_webhooks, [:customer_id, :nocrm_id]
  end
end
