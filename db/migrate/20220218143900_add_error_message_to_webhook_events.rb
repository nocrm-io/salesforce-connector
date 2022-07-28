class AddErrorMessageToWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :webhook_events, :error_message, :json
  end
end
