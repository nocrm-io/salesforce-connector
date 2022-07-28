class RenameErrorMessageInWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    rename_column :webhook_events, :error_message, :result
  end
end
