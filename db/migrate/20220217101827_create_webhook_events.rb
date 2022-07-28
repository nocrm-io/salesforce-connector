class CreateWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :webhook_events do |t|
      t.references :customer, null: false, foreign_key: true
      t.json :data
      t.integer :status

      t.timestamps
    end
  end
end
