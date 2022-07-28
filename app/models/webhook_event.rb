class WebhookEvent < ApplicationRecord
  acts_as_tenant :customer

  enum status: [:pending, :processing, :ok, :error], _prefix: true

  def process!
    status_processing!

    result =
      case data['event']
      when 'lead.creation', 'lead.any_update'
        WebhookEvent::LeadCreatedOrUpdated.new(self).process
      else
        { body: "#{data['event']} is not implemented", status: :error }
      end

    update(result: result[:body], status: result[:status])
  end
end

