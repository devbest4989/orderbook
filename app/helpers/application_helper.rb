module ApplicationHelper
  PAYMENT_TERMS = [
    '7-Days : Due on 7 days after Date of Invoice Issued',
    '14-Days : Due on 14 days after Date of Invoice Issued',
    '30-Days : Due on 30 days after Date of Invoice Issued',
    '20th of Following Month : Due on 20th of following month'
    ].freeze  

  PAYMENT_MODE = [
    'Cash',
    'Cheque',
    'Credit Card',
    'Bank Transfer (Direct Credit)',
    'Direct Debit ( Bank Remittance)'
    ].freeze  

  def custom_link_to_remove_fields name, f, opts={}
    f.hidden_field(:_destroy) + __custom_link_to_function(name, "remove_fields(this)", 'red', class: opts[:class])
  end

  def custom_link_to_add_fields name, f, association, opts={}
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render(association.to_s.singularize + "_fields", :f => builder)
    end
    __custom_link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", 'green', class: opts[:class])
  end

  private
  def __custom_link_to_function name, on_click_event, button_color, opts={}
    link_to(name.html_safe, 'javascript:void(0);', {onclick: on_click_event, class: "btn btn-#{button_color} btn-xs #{opts[:class]}"})
  end

end
