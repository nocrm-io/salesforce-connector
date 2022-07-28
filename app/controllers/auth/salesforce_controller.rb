class Auth::SalesforceController < ApplicationController
  skip_before_action :authenticate_customer!, except: :show
  skip_before_action :set_tenant, only: [:connect, :oauth2callback]

  ##############################################
  ##### No current_tenant on these actions #####
  ##############################################
  def connect
    client = OAuth2::Client.new(ENV["SALESFORCE_CONSUMER_KEY"],
                                ENV["SALESFORCE_CONSUMER_SECRET"],
                                {authorize_url: Settings.salesforce.authorize_url})

    # in order to keep data through the oauth2 process
    # We need to generate a private and public key in order to sign the state_param
    state_param = { key: Rails.application.credentials.oauth[:public_key] }
    state_param[:customer_id] = params[:customer_id]

    # We can also add a list of scope from https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_tokens_scopes.htm&type=5
    # but don't really know which ones we need
    redirect_to(client.auth_code.authorize_url(redirect_uri: SalesforceApi.redirect_uri, response_type: 'code',
                                               state: Encryption.encode(Rails.application.credentials.oauth[:private_key], state_param.to_json)), allow_other_host: true)
  end

  def oauth2callback
    if params[:code].present?
      # We check the state parameter is still the same
      state_param = JSON.parse(Encryption.decode(Rails.application.credentials.oauth[:private_key], params[:state]))
      if state_param['key'] != Rails.application.credentials.oauth[:public_key]
        return redirect_to action: :error
      end

      client = OAuth2::Client.new(ENV["SALESFORCE_CONSUMER_KEY"],
                                  ENV["SALESFORCE_CONSUMER_SECRET"],
                                  { token_url: Settings.salesforce.token_url })
      data = client.auth_code.get_token(params[:code], redirect_uri: SalesforceApi.redirect_uri, grant_type: 'authorization_code')

      customer_id = state_param['customer_id']

      sales_data = { access_token: data.token, refresh_token: data.refresh_token, domain: data.params["instance_url"] }
      customer = Customer.find_by(id: customer_id)
      if customer
        ActsAsTenant.with_tenant(customer) do
          if customer.salesforce_account.present?
            customer.salesforce_account.update(sales_data)
          else
            customer.salesforce_account = SalesforceAccount.create(sales_data)
          end
          customer.salesforce_account.sync_sf_fields
        end
      end
    end

    redirect_to auth_salesforce_url, notice: "You successfully connected your Salesforce account."
  end

  ##############################################
  ####### Actions on with the logged user ######
  ######### with a current_tenant set ##########
  ##############################################

  def show
    # the page to display the status of the connection
  end

  def synchronize_fields
    if current_customer.salesforce_account.sync_sf_fields
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def revoke_token
    if current_customer.salesforce_account
      SalesforceApi.revoke_token
      current_tenant.salesforce_account.destroy
    end
    redirect_to auth_salesforce_url, notice: "You successfully disconnected your Salesforce account."
  end
end
