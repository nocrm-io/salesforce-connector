class SalesforceStage < ApplicationRecord
  acts_as_tenant :customer

  has_many :mappings, as: :salesforce_object, dependent: :destroy

end
