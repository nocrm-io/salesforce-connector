class NocrmStep < ApplicationRecord
  acts_as_tenant :customer

  has_many :mappings, as: :nocrm_object
  has_many :salesforce_stages, through: :mappings, source_type: "SalesforceStage", source: :salesforce_object

  # Validations
  validates_uniqueness_of :nocrm_id, scope: :customer_id

  def stage_id
    salesforce_stages.ids.first
  end

  def stage_id=(id)
    mappings.first.destroy if mappings.any?

    mappings.create(salesforce_object_type: "SalesforceStage", salesforce_object_id: id)
  end

  def self.pipelines
    pipelines = []
    pluck(:pipeline_id, :pipeline_name).uniq.map { |pipe| pipelines << { id: pipe.first, name: pipe.second } }
    pipelines.uniq.flatten
  end
end
