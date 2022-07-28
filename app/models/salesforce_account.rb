class SalesforceAccount < ApplicationRecord
  acts_as_tenant :customer

  after_destroy do
    customer.salesforce_fields.destroy_all
    customer.salesforce_stages.destroy_all
  end

  def sync_sf_fields
    field_attributes = {
      name: 'nocrm_id',
      metadata: { type: 'Number', label: 'noCRM lead id', externalId: true, precision: 18, scale: 0, unique: true }
    }
    SalesforceApi.create_custom_field('Opportunity', field_attributes)

    SalesforceService.sync_all_fields(customer)
  end
end
