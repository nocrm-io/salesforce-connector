class Mapping < ApplicationRecord
  acts_as_tenant :customer
  belongs_to :nocrm_object, polymorphic: true
  belongs_to :salesforce_object, polymorphic: true

  validates :salesforce_object_type, format: { with: /SalesforceStage/ }, if: :nocrm_step?
  validates :nocrm_object_type, format: { with: /NocrmStep/ }, if: :salesforce_stage?

  def nocrm_step?
    nocrm_object.is_a? NocrmStep
  end

  def salesforce_stage?
    salesforce_object.is_a? SalesforceStage
  end

  # Getter returning the nocrm_object global_id
  # Used in form & controller
  def nocrm_object_gid
    self.nocrm_object&.to_global_id
  end

  # Setter to allow replacing a nocrm_object for a given global_id value
  # Used in form & controller
  def nocrm_object_gid=(gid)
    self.nocrm_object = GlobalID::Locator.locate(gid)
  end
end

