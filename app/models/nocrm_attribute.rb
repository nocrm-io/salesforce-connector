class NocrmAttribute < ApplicationRecord
  acts_as_tenant :customer

  has_many :mappings, as: :nocrm_object
  has_many :salesforce_fields, through: :mappings, source_type: "SalesforceField", source: :salesforce_object

  def self.grouped_fields_for_select
    all.map { |f| [f.name, f.to_global_id] }
  end
end
