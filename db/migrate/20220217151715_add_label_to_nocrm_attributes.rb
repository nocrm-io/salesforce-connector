class AddLabelToNocrmAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :nocrm_attributes, :label, :string
  end
end
