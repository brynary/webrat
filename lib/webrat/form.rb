module Webrat
  class Form
    def initialize(page, form)
      @page = page
      @form = form
      @params = default_params
    end
    
    def set(input_element, value)
      new_param = param_parser.parse_query_parameters("#{input_element.attributes["name"]}=#{value}")
      merge(new_param)
    end
  
    def unset(input_element)
      @params.delete(input_element.attributes['name'])
    end

    def find_field(*args)
      FieldFinder.new(@form, *args).find
    end
    
    def find_button(name = nil)
      ButtonFinder.new(@form, name).find
    end
    
    def submit
      Page.new(@page.session, form_action, form_method, @params)
    end

  protected
    
    # def find_field_by_name(name) # :nodoc:
    #   find_element_by_name("input", name) || find_element_by_name("textarea", name)
    # end
    # 
    # def add_default_params_for(form) # :nodoc:
    #   add_default_params_from_inputs_for(form)
    #   add_default_params_from_checkboxes_for(form)
    #   add_default_params_from_radio_buttons_for(form)
    #   add_default_params_from_textareas_for(form)
    #   add_default_params_from_selects_for(form)
    # end
  
    def default_params
      {}
    end
  
    def add_default_params_from_radio_buttons_for(form) # :nodoc:
      (form / "input[@type='radio][@checked='checked']").each do |input|
        add_form_data(input, input.attributes["value"])
      end
    end
    
    def add_default_params_from_checkboxes_for(form) # :nodoc:
      (form / "input[@type='checkbox][@checked='checked']").each do |input|
        add_form_data(input, input.attributes["value"] || "on")
      end
    end
    
    def add_default_params_from_selects_for(form) # :nodoc:
      (form / "select").each do |select|
        selected_options = select / "option[@selected='selected']"
        selected_options = select / "option:first" if selected_options.empty? 
        selected_options.each do |option|
          add_form_data(select, option.attributes["value"] || option.innerHTML)
        end
      end
    end
    
    def add_default_params_from_inputs_for(form) # :nodoc:
      (form / "input").each do |input|
        next unless %w[text password hidden].include?(input.attributes["type"])
        add_form_data(input, input.attributes["value"])
      end
    end
    
    def add_default_params_from_textareas_for(form) # :nodoc:
      (form / "textarea").each do |input|
        add_form_data(input, input.inner_html)
      end
    end
  
    def form_method
      @form.attributes["method"].blank? ? :get : @form.attributes["method"].downcase
    end
    
    def form_action
      @form.attributes["action"].blank? ? current_url : @form.attributes["action"]
    end
    
    def param_parser
      if defined?(CGIMethods)
        CGIMethods
      else
        ActionController::AbstractRequest
      end
    end
    
    def merge(new_param)
      new_param.each do |key, value|
        case @params[key]
        when Hash, HashWithIndifferentAccess
          merge_hash_values(@params[key], value)
        when Array
          @params[key] += value
        else
          @params[key] = value
        end
      end
    end
  
    def merge_hash_values(a, b) # :nodoc:
      a.keys.each do |k|
        if b.has_key?(k)
          case [a[k], b[k]].map(&:class)
          when [Hash, Hash]
            a[k] = merge_hash_values(a[k], b[k])
            b.delete(k)
          when [Array, Array]
            a[k] += b[k]
            b.delete(k)
          end
        end
      end
      a.merge!(b)
    end
    
  end
end