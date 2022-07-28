class CustomersController < ApplicationController
  def show
    flash.keep
  end

  def update
    if current_customer.update(customer_params)
      NocrmApi.ping_api(current_customer)
      current_tenant.create_nocrm_attributes
      NocrmSyncService.sync_steps(current_customer)
      NocrmSyncService.sync_field_types(current_customer)
      NocrmSyncService.create_webhooks(current_customer)
      redirect_to customer_url, notice: "Your noCRM account is connected."
    else
      redirect_to customer_url, alert: "An error occurred, please check your inputs"
    end
  rescue RestClient::Unauthorized
    current_customer.update(api_key: nil)
    flash[:alert] = "Unauthorized API connection, please check your settings."
    redirect_to action: :show
  rescue URI::InvalidURIError
    current_customer.update(api_key: nil, nocrm_account: nil)
    flash[:alert] = "The noCRM account subdomain is not formatted properly."
    redirect_to action: :show
  end

  def ping_api
    NocrmApi.ping_api(current_customer)
    redirect_to customer_url, notice: "Your API connection is working!"
  rescue RestClient::Unauthorized
    redirect_to customer_url, alert: "Unauthorized API connection, please check your settings."
  end

  def revoke_token
    NocrmSyncService.revoke_token(current_customer)
    redirect_to customer_url, notice: "Your connection to noCRM has been revoked!"
  end

  private

  def customer_params
    params.require(:customer).permit(:nocrm_account, :api_key)
  end

end
