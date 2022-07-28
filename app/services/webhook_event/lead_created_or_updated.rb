# Service in charge of managing an noCRM webhook event of type lead.creation or lead.any_update and send the
# data to Salesforce
class WebhookEvent::LeadCreatedOrUpdated
  class SynchronizationError < StandardError; end

  def initialize(webhook_event)
    @webhook_event = webhook_event
    @result_body = {}
    @salesforce_opportunity = {}
    @salesforce_contact = {}
    @salesforce_account = {}
  end

  def process
    prepare_data_from_mapping
    push_data
    { body: @result_body, status: :ok }
  rescue SynchronizationError => e
    { body: @result_body, status: :error }
  end

  private

  def prepare_data_from_mapping
    @salesforce_opportunity['nocrm_id__c'] = @webhook_event.data.dig('data', 'id')

    Mapping.all.each do |mapping|
      case mapping.nocrm_object
      when NocrmAttribute
        nocrm_value = @webhook_event.data.dig('data', *mapping.nocrm_object.name.split('.'))
        set_salesforce_data_for(mapping.salesforce_object, nocrm_value)
      when NocrmFieldType
        nocrm_data =
          case mapping.nocrm_object.parent_type
          when 'lead' then lead_from_nocrm_api
          when 'client' then client_from_nocrm_api
          end
        nocrm_value = nocrm_data&.dig('extended_info', 'fields_by_name', mapping.nocrm_object.name)
        set_salesforce_data_for(mapping.salesforce_object, nocrm_value)
      when NocrmStep
        if lead_from_nocrm_api['step_id'] == mapping.nocrm_object.nocrm_id
          @salesforce_opportunity['StageName'] = mapping.salesforce_object.name
        end
      end
    end
  end

  def push_data
    salesforce_account_id = create_or_update_account(@salesforce_account)

    @salesforce_opportunity['AccountId'] = salesforce_account_id if salesforce_account_id
    @salesforce_contact['AccountId'] = salesforce_account_id if salesforce_account_id

    create_or_update_contact(@salesforce_contact)
    create_or_update_opportunity(@salesforce_opportunity)
  end

  # Create or update existing Account with the given Name in account params or create a new account
  # Returns the account_id or raises a SynchronizationError
  def create_or_update_account(account_params)
    accounts = SalesforceApi.client.query_all("SELECT Id FROM Account WHERE Name = '#{account_params['Name']}'")

    if accounts.count > 0
      account_id = SalesforceApi.update_account(accounts.first.Id, account_params)
      @result_body['Account'] = { message: 'Account updated' }
    else
      account_id = SalesforceApi.create_account(account_params)
      @result_body['Account'] = { message: 'Account created' }
    end

    @result_body['Account'][:status] = :success
    account_id
  rescue Restforce::ResponseError => e
    @result_body['Account'] = { message: e.response[:body] }
    if skip_account_on_failure?
      @result_body['Account'][:status] = :skipped
      nil
    else
      @result_body['Account'][:status] = :error
      raise SynchronizationError.new
    end
  end

  # Create or update existing opportunity with external nocrm_id
  # Returns the opportunity_id or raises a SynchronizationError
  def create_or_update_opportunity(opportunity_params)
    opportunity_id = SalesforceApi.client.upsert!('Opportunity', 'nocrm_id__c', **opportunity_params)
    @result_body['Opportunity'] = { status: :success, message: "Opportunity created/updated" }
    opportunity_id
  rescue Restforce::ResponseError => e
    @result_body['Opportunity'] = { status: :error, message: e.response[:body] }
    raise SynchronizationError.new
  end

  # Tries to create a contact and rescue DuplicatesDetected error and update existing record
  # Returns the contact_id or raises a SynchronizationError
  def create_or_update_contact(contact_params)
    contact_id = SalesforceApi.create_contact(contact_params)
    @result_body['Contact'] = { status: :success, message: 'Contact created' }
    contact_id
  rescue Restforce::ErrorCode::DuplicatesDetected => e
    contact_id = e.response[:body].dig 0, "duplicateResut", "matchResults", 0, "matchRecords", 0, "record", "Id"
    SalesforceApi.update_contact(contact_id, contact_params)
    @result_body['Contact'] = { status: :success, message: e.response[:body] }
    contact_id
  rescue Restforce::ResponseError => e
    @result_body['Contact'] = { message: e.response[:body] }
    if skip_contact_on_failure?
      @result_body['Contact'][:status] = :skipped
    else
      @result_body['Contact'][:status] = :error
      raise SynchronizationError.new
    end
  end

  def set_salesforce_data_for(salesforce_object, nocrm_value)
    case salesforce_object.object_type
    when 'Opportunity'
      nocrm_value = salesforce_object.default_value(@salesforce_opportunity) unless nocrm_value
      @salesforce_opportunity[salesforce_object.name] = nocrm_value
    when 'Account'
      @salesforce_account[salesforce_object.name] = nocrm_value
    when 'Contact'
      @salesforce_contact[salesforce_object.name] = nocrm_value
    end
  end

  def client_from_nocrm_api
    client_id = @webhook_event.data.dig('data', 'client', 'id')
    return nil unless client_id

    @client_from_nocrm_api ||= NocrmApi.get_client(ActsAsTenant.current_tenant, client_id)
  end

  def lead_from_nocrm_api
    @lead_from_nocrm_api ||= NocrmApi.get_lead(ActsAsTenant.current_tenant, @webhook_event.data.dig('data', 'id'))
  end

  # Should we skip creating or updating account in case of failure and continue ?
  def skip_account_on_failure?
    SalesforceField::OBJECT_TYPES.dig('Account', 'skip_on_failure')
  end

  # Should we skip creating or updating contact in case of failure and continue ?
  def skip_contact_on_failure?
    SalesforceField::OBJECT_TYPES.dig('Contact', 'skip_on_failure')
  end
end