class NocrmApi

  def self.api_root_url(customer)
    "#{Settings.protocol}#{customer.nocrm_account}.#{Settings.nocrm_domain}/api/v2"
  end

  def self.webhook_events_target(customer)
    "#{Settings.app_url}/webhook_events?token=#{customer.webhooks_token}"
  end

  def self.set_headers(customer)
    { 'X-API-KEY' => customer.api_key, content_type: :json, accept: "application/json" }
  end

  def self.retrieve_all_steps(customer)
    url = "#{NocrmApi.api_root_url(customer)}/steps"

    JSON.parse(RestClient.get url, NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    []
  end

  def self.retrieve_all_fields(customer)
    url = "#{NocrmApi.api_root_url(customer)}/fields"

    JSON.parse(RestClient.get url, NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    []
  end

  def self.get_lead(customer, lead_id)
    url = "#{NocrmApi.api_root_url(customer)}/leads/#{lead_id}"

    JSON.parse(RestClient.get url, NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    []
  end

  def self.get_client(customer, client_id)
    url = "#{NocrmApi.api_root_url(customer)}/clients/#{client_id}"

    JSON.parse(RestClient.get url, NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    []
  end

  def self.create_webhook(customer, event)
    url = "#{NocrmApi.api_root_url(customer)}/webhooks"

    parameters = { event: event }
    parameters[:target_type] = 'url'
    parameters[:target] = NocrmApi.webhook_events_target(customer)
    parameters[:name] = "Sync for SalesForce integration"

    JSON.parse(RestClient.post url, parameters.to_json,NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    []
  end

  def self.delete_webhook(customer, nocrm_webhook_id)
    url = "#{NocrmApi.api_root_url(customer)}/webhooks/#{nocrm_webhook_id}"
    JSON.parse(RestClient.delete(url, NocrmApi.set_headers(customer)))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    {}
  end

  def self.revoke_api_key(customer)
    url = "#{NocrmApi.api_root_url(customer)}/auth/revoke_api_key"
    RestClient.post(url, '', NocrmApi.set_headers(customer))
  rescue => e
    Rails.logger.debug("------> exception = #{e.message}")
    {}
  end

  def self.ping_api(customer)
    url = "#{NocrmApi.api_root_url(customer)}/ping"
    RestClient.get url, NocrmApi.set_headers(customer)
  end
end