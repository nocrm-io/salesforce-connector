# Customize form errors instead of default Rails error wrapper
ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html = ""

  form_fields = [
    "textarea",
    "input",
    "select"
  ]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, " + form_fields.join(", ")
  elements.each do |e|
    if form_fields.include? e.node_name
      e.add_class("form-error")

      html = if e.get_attribute("type") == "checkbox"
        e.to_s
      elsif instance.error_message.respond_to? :each
        %(#{e}<p class="form-hint error">&nbsp;#{instance.object.class.human_attribute_name(instance.send(:sanitized_method_name))} #{instance.error_message.uniq.to_sentence}</p>)
      else
        %(#{e}<p class="form-hint error">&nbsp;#{instance.object.class.human_attribute_name(instance.send(:sanitized_method_name))} #{instance.error_message}</p>)
      end
    else
      html = e.to_s
    end
  end

  html.html_safe
end
