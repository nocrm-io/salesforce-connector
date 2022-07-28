class SalesforceService
  def self.sync_fields_from(sf_object_name, customer)
    fields = SalesforceApi.get_fields_from(sf_object_name)

    fields.each do |field|
      next unless field['createable']
      next if field['name'] == 'StageName' || field['name'] == "nocrm_id__c"

      is_required = !field['nillable'] && !field['defaultedOnCreate']
      attributes = { customer_id: customer.id, object_type: sf_object_name, name: field['name'], label: field['label'], is_required: is_required }
      existing_field = SalesforceField.find_or_initialize_by({customer_id: customer.id, object_type: sf_object_name, name: field['name']})
      if existing_field.new_record?
        existing_field.is_required = attributes[:is_required]
        existing_field.label = attributes[:label]
        existing_field.save
      else
        existing_field.update(attributes)
      end
    end
  end

  def self.sync_stages(customer)
    client = SalesforceApi.client
    stages = client.picklist_values('Opportunity', 'StageName')

    stages.each_with_index do |stage, i|
      attributes = { customer_id: customer.id, name: stage.value, position: i }
      existing_field = SalesforceStage.find_or_initialize_by({ customer_id: customer.id, name: stage.value })
      if existing_field.new_record?
        existing_field.position = attributes[:position]
        existing_field.save
      else
        existing_field.update(attributes)
      end
    end
  end

  def self.sync_all_fields(customer)
    sync_fields_from('Account', customer)
    sync_fields_from('Opportunity', customer)
    sync_fields_from('Contact', customer)
    # Steps
    sync_stages(customer)
    # Fill salesforce_id or delete fields
    sync_custom_fields(customer)
  end

  def self.sync_custom_fields(customer)
    custom_fields = SalesforceApi.get_custom_fields
    custom_fields.each do |custom_field|
      field_to_delete = false
      name = custom_field.DeveloperName

      if name.slice(name.length - 4, 4) == "_del" #field is deleted on salesforce
        name = custom_field.DeveloperName.delete_suffix('_del')
        field_to_delete = true
      end
      sf = SalesforceField.find_by({ customer_id: customer.id, object_type: custom_field.TableEnumOrId, name: "#{name}__c" })

      if sf.present?
        if field_to_delete
          sf.destroy
        else
          sf.update({ salesforce_id: custom_field.Id })
        end
      end
    end
  end

end
