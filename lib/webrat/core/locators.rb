module Webrat
  module Locators

    def find_field(*args)
      # This is the default locator strategy
      
      field_with_id(*args)    ||
      field_with_name(*args)  ||
      field_labeled(*args)
    end
    
    def field_labeled(label, *field_types)
      if field_types.empty?
        field_types = [TextField, TextareaField, CheckboxField, RadioField, HiddenField]
      end
      
      forms.each do |form|
        result = form.find_field_by_label(label, *field_types)
        return result if result
      end
      
      flunk("Could not find #{field_types.inspect}: #{label.inspect}")
    end
    
    def field_with_id(id, *field_types)
      if field_types.empty?
        field_types = [TextField, TextareaField, CheckboxField, RadioField, HiddenField]
      end
      
      forms.each do |form|
        result = form.find_field_by_id(id, *field_types)
        return result if result
      end
      
      return nil
    end
    
    def field_with_name(name, *field_types)
      if field_types.empty?
        field_types = [TextField, TextareaField, CheckboxField, RadioField, HiddenField]
      end
      
      forms.each do |form|
        result = form.find_field_by_name(name, *field_types)
        return result if result
      end
      
      return nil
    end
    
    def find_select_option(option_text, id_or_name_or_label)
      if id_or_name_or_label
        field = find_field(id_or_name_or_label, SelectField)
        return field.find_option(option_text)
      else
        forms.each do |form|
          result = form.find_select_option(option_text)
          return result if result
        end
      end
        
      flunk("Could not find option #{option_text.inspect}")
    end
    
    def find_button(value)
      forms.each do |form|
        button = form.find_button(value)
        return button if button
      end
      flunk("Could not find button #{value.inspect}")
    end
    
    def find_area(area_name)
      areas.select{|area| area.matches_text?(area_name)}.first || flunk("Could not find area with name #{area_name}")
    end
    
    def find_link(text, selector = nil)
      matching_links = links_within(selector).select do |possible_link|
        possible_link.matches_text?(text)
      end
      
      if matching_links.any?
        matching_links.min { |a, b| a.text.length <=> b.text.length }
      else
        flunk("Could not find link with text #{text.inspect}")
      end
    end
    
  end
end