class SalesforceField < ApplicationRecord
  acts_as_tenant :customer
  has_many :mappings, as: :salesforce_object, dependent: :destroy

  OBJECT_TYPES = {
    Account: { skip_on_failure: true },
    Contact: { skip_on_failure: true },
    Opportunity: {}
  }.with_indifferent_access

  # Scopes
  scope :accounts, -> { where(object_type: "Account") }
  scope :contacts, -> { where(object_type: "Contact") }
  scope :opportunities, -> { where(object_type: "Opportunity") }
  scope :mapped_accounts, -> { joins(:mappings).accounts.where.not(mappings: nil) }
  scope :mapped_contacts, -> { joins(:mappings).contacts.where.not(mappings: nil) }
  scope :mapped_opportunities, -> { joins(:mappings).opportunities.where.not(mappings: nil) }
  scope :mapped, -> { where(id: Mapping.where(salesforce_object_type: 'SalesforceField').pluck(:salesforce_object_id)) }

  def self.grouped_fields_for_select
    all.group_by(&:object_type).map do |object_type, fields|
      [object_type , fields.map { |field| [field.name, field.id] }]
    end
  end

  def default
    case
    when name == 'Name' && opportunity?
      {
        strategy: 'The noCRM lead ID will be used if not found in data received from noCRM',
        value: ->(opportunity_data) { opportunity_data['id'] }
      }
    when name == 'CloseDate' && opportunity?
      {
        strategy: 'Will be set to 1 month from now if not found in data received from noCRM',
        value: ->(_) { 1.month.from_now.strftime "%Y-%m-%d" }
      }
    end
  end

  def default_value(data)
    default&.dig(:value)&.call(data)
  end

  def opportunity?
    object_type == 'Opportunity'
  end
end
