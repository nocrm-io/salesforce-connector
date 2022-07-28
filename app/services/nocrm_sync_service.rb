class NocrmSyncService

  def self.create_webhooks(customer)
    # Creation of the webhooks for the steps, pipeline and default fields
    webhook_token = customer.webhooks_token
    unless webhook_token
      Rails.logger.debug("------> no TOKEN to create the webhook")
      return
    end

    events = %w[account.step.created account.step.updated account.step.deleted account.pipeline.updated
                account.default_field.created account.default_field.updated account.default_field.deleted
                lead.creation lead.any_update]
    events.each do |event|
      nocrm_webhook = NocrmApi.create_webhook(customer, event)
      if nocrm_webhook.present?
        NocrmWebhook.create(nocrm_id: nocrm_webhook['id'], event: event)
      end
    end
  end

  def self.sync_steps(customer)
    # Retrieve the steps from noCRM
    nocrm_steps = NocrmApi.retrieve_all_steps(customer)

    # Fill up the table
    if nocrm_steps.present?
      nocrm_steps.each do |nocrm_step|
        already_synced_step = NocrmStep.find_by(nocrm_id: nocrm_step['id'])
        if already_synced_step
          NocrmSyncService.update_step(nocrm_step, already_synced_step)
        else
          NocrmSyncService.create_step(nocrm_step)
        end
      end
    end
  end

  def self.sync_field_types(customer)
    nocrm_fields = NocrmApi.retrieve_all_fields(customer)

    if nocrm_fields.present?
      nocrm_fields.each do |nocrm_field|
        already_synced_field = NocrmFieldType.find_by(nocrm_id: nocrm_field['id'])
        if already_synced_field
          NocrmSyncService.update_field_type(nocrm_field, already_synced_field)
        else
          NocrmSyncService.create_field_type(nocrm_field)
        end
      end
    end
  end

  def self.revoke_token(customer)
    customer.nocrm_webhooks.each do |nocrm_webhook|
      NocrmApi.delete_webhook(customer, nocrm_webhook.nocrm_id)
      nocrm_webhook.destroy
    end

    NocrmApi.revoke_api_key(customer)
    customer.update(api_key: nil)
    NocrmAttribute.destroy_all
    NocrmFieldType.destroy_all
    NocrmStep.destroy_all
  end

  def self.create_step(nocrm_step_h)
    return "Step already existing" if NocrmStep.find_by(nocrm_id: nocrm_step_h['id'])

    NocrmStep.create(nocrm_id: nocrm_step_h['id'],
                     name: nocrm_step_h['name'],
                     pipeline_name: nocrm_step_h['pipeline']['name'],
                     pipeline_id: nocrm_step_h['pipeline']['id'],
                     position: nocrm_step_h['position'])
  end

  def self.update_step(nocrm_step_h, existing_nocrm_step=nil)
    existing_nocrm_step ||= NocrmStep.find_by(nocrm_id: nocrm_step_h['id'])

    att_to_update = Hash.new.tap do |h|
      h[:name] = nocrm_step_h['name'] if existing_nocrm_step.name != nocrm_step_h['name']
      h[:pipeline_name] = nocrm_step_h['pipeline']['name'] if existing_nocrm_step.pipeline_name != nocrm_step_h['pipeline']['name']
      h[:position] = nocrm_step_h['position'] if existing_nocrm_step.position != nocrm_step_h['position']
    end
    existing_nocrm_step.update(att_to_update) if att_to_update.present?
  end

  def self.delete_step(nocrm_step_h)
    nocrm_step = NocrmStep.find_by(nocrm_step_h['id'])
    nocrm_step.destroy if nocrm_step
  end

  def self.update_pipeline(nocrm_pipe_h)
    nocrm_steps = NocrmStep.where(pipeline_id: nocrm_pipe_h['id'])
    nocrm_steps.update_all(pipeline_name: nocrm_pipe_h[:name])
  end

  def self.create_field_type(nocrm_field_h)
    return "Field already existing" if NocrmFieldType.find_by(nocrm_id: nocrm_field_h['id'])

    NocrmFieldType.create(nocrm_id: nocrm_field_h['id'],
                          field_type: nocrm_field_h['type'],
                          parent_type: nocrm_field_h['parent_type'],
                          name: nocrm_field_h['name'])
  end

  def self.update_field_type(nocrm_field_h, existing_nocrm_field_type=nil)
    existing_nocrm_field_type ||= NocrmFieldType.find_by(nocrm_id: nocrm_field_h['id'])

    att_to_update = Hash.new.tap do |h|
      h[:field_type] = nocrm_field_h['type'] if existing_nocrm_field_type.field_type != nocrm_field_h['type']
      h[:parent_type] = nocrm_field_h['parent_type'] if existing_nocrm_field_type.parent_type != nocrm_field_h['parent_type']
      h[:name] = nocrm_field_h['name'] if existing_nocrm_field_type.name != nocrm_field_h['name']
    end
    existing_nocrm_field_type.update(att_to_update) if att_to_update.present?
  end

  def self.delete_field_type(nocrm_field_h)
    nocrm_field_type = NocrmFieldType.find_by(nocrm_field_h['id'])
    nocrm_field_type.destroy if nocrm_field_type
  end
end
