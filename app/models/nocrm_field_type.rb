class NocrmFieldType < ApplicationRecord
  acts_as_tenant :customer

  has_many :mappings, as: :nocrm_object
  has_many :salesforce_fields, through: :mappings, source_type: "SalesforceField", source: :salesforce_object

  # Validations
  validates_uniqueness_of :nocrm_id, scope: :customer_id

  def self.grouped_fields_for_select
    all.map { |f| [(f.parent_type ? "#{f.parent_type}.#{f.name}" : f.parent_type), f.to_global_id] }
  end
end
