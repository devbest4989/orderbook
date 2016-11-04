module DeviseHelper
  def devise_error_messages!
    return "" unless devise_error_messages?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)
    sentence = "There are #{resource.errors.count} error#{if resource.errors.count > 1 then 's' end}.";

    html = <<-HTML
    <div id="error_explanation" style="text-align: left; color: darkred;">
      <h2 style="text-align: center;">#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

end