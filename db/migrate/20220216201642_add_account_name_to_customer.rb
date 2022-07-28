class AddAccountNameToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :nocrm_account, :string
  end
end
