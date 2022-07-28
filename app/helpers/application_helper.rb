module ApplicationHelper

  def flashover(message = nil, options = {})
    message ||= flash[:success].presence || flash[:notice].presence || flash[:alert].presence
    return unless message

    options[:color] ||= 'success' if flash[:success].presence
    options[:color] ||= 'success' if flash[:notice].presence
    options[:color] ||= 'danger' if flash[:alert].presence

    rendered = raw 'flash("'+ escape_javascript(message) + '", {color: "'+ options[:color] +'"})'
    flash&.clear
    return rendered
  end

  def setup_completed?
    return true if Mapping.count.zero?

    setup_fields_completed? && setup_steps_completed?
  end

  def setup_fields_completed?
    return true if Mapping.count.zero?

    SalesforceField.where(is_required: true).where.not(name: "nocrm_id__c").select { |sf_field| sf_field.mappings.count.zero? }.empty?
  end

  def setup_steps_completed?
    return true if Mapping.count.zero?

    NocrmStep.all.select { |nocrm_step| nocrm_step.mappings.count.zero? }.empty?
  end

end
