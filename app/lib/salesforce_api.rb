module SalesforceApi
  API_VERSION = '41.0'.freeze

  def self.salesforce_account
    SalesforceAccount.last
  end

  def self.redirect_uri
    "#{Settings.app_url}#{Settings.salesforce.redirect_path}"
  end

  def self.client
    Restforce.new(
      oauth_token: salesforce_account.access_token,
      refresh_token: salesforce_account.refresh_token,
      instance_url: salesforce_account.domain,
      client_id: ENV["SALESFORCE_CONSUMER_KEY"],
      client_secret: ENV["SALESFORCE_CONSUMER_SECRET"],
      authentication_callback: Proc.new { |x| puts "CALLBACK ___  #{x.to_s}" },
      api_version: '41.0'
    )
  end

  def self.tooling
    Restforce.tooling(
      oauth_token: salesforce_account.access_token,
      refresh_token: salesforce_account.refresh_token,
      instance_url: salesforce_account.domain,
      client_id: ENV["SALESFORCE_CONSUMER_KEY"],
      client_secret: ENV["SALESFORCE_CONSUMER_SECRET"],
      authentication_callback: Proc.new { |x| puts "CALLBACK ___  #{x.to_s}" },
      api_version: '41.0'
    )
  end

  def self.create_opportunity(opportunity)
    client.create!('Opportunity', **opportunity)
  end

  def self.create_contact(contact)
    client.create!('Contact', **contact)
  end

  # Updates an existing contact & returns the contact id
  def self.update_contact(contact_id, contact)
    client.update!('Contact', **contact.merge(Id: contact_id)) && contact_id
  end

  def self.create_account(account)
    client.create!('Account', **account)
  end

  # updates an existing account & returns the account id
  def self.update_account(account_id, account)
    client.update!('Account', **account.merge(Id: account_id)) && account_id
  end

  def self.get_opportunities
    client.query_all("select Name, StageName, CloseDate from Opportunity")
  end

  def self.get_fields_from(sf_object_name)
    data = client.describe(sf_object_name)
    data.fields
  end

  def self.create_custom_field(sf_object, field_attributes)
    tooling.create!('CustomField',
      {
        'FullName' => "#{sf_object}.#{field_attributes[:name]}__c",
        'Metadata' => field_attributes[:metadata]
      }
    )
  rescue Restforce::ErrorCode::DuplicateDeveloperName
    true
  end

  def self.get_custom_fields
    tooling.query("Select Id, TableEnumOrId, DeveloperName from CustomField Where TableEnumOrId IN ('Account', 'Opportunity', 'Contact')")
  end

  def self.revoke_token
    RestClient.post("#{salesforce_account.domain}/services/oauth2/revoke",
                    URI.encode_www_form([['token', SalesforceAccount.last.refresh_token]]),
                    { content_type: 'application/x-www-form-urlencoded' })
  rescue => e
    Rails.logger.debug("-----> message = #{e.message}")
    Rails.logger.debug("---> e.response = #{e.response}")
  end
end
