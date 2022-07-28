class AddSalesforceIdToSalesforceFields < ActiveRecord::Migration[7.0]
  def change
    add_column :salesforce_fields, :salesforce_id, :string
  end
end
