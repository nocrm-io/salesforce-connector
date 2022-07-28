class WebhookEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_customer!, only: [:create]
  before_action :authenticate_webhook, only: [:create]

  def create
    data = params[:webhook_event][:data]
    case params[:webhook_event][:event]
    when 'account.step.created'
      NocrmSyncService.create_step(data)
    when 'account.step.updated'
      NocrmSyncService.update_step(data)
    when 'account.step.deleted'
      NocrmSyncService.delete_step(data)
    when 'account.pipeline.updated'
      NocrmSyncService.update_pipeline(data)
    when 'account.default_field.created'
      NocrmSyncService.create_field_type(data)
    when 'account.default_field.updated'
      NocrmSyncService.update_field_type(data)
    when 'account.default_field.deleted'
      NocrmSyncService.delete_field_type(data)
    when 'lead.creation', 'lead.any_update'
      webhook_event = WebhookEvent.create(data: params[:webhook_event])
      webhook_event.process!
    end
    head :ok
  end

  def index
    @webhook_events = WebhookEvent.order(id: :desc).page(params[:page]).per(100)
  end

  def reprocess
    @webhook_event = WebhookEvent.find(params[:id])
    @webhook_event.process!
    render @webhook_event
  end

  private

  def authenticate_webhook
    customer = Customer.find_by(webhooks_token: params[:token])
    if customer && signature_valid?(customer)
      customer.current_tenant!
    else
      head :unauthorized
    end
  end

  def signature_valid?(customer)
    params[:webhook_event][:signature] == Digest::SHA1.hexdigest(params[:webhook_event][:id].to_s + customer.api_key)
  end
end
