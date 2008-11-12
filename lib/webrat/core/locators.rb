require "webrat/core_extensions/detect_mapped"

module Webrat
  module Locators

    def field(*args)
      # This is the default locator strategy
      find_field_with_id(*args) ||
      find_field_named(*args)   ||
      field_labeled(*args)      ||
      flunk("Could not find field: #{args.inspect}")
    end
    
    def field_labeled(label, *field_types)
      find_field_labeled(label, *field_types) ||
      flunk("Could not find field labeled #{label.inspect}")
    end

    def field_named(name, *field_types)
      find_field_named(name, *field_types) ||
      flunk("Could not find field named #{name.inspect}")
    end
    
    def field_with_id(id, *field_types)
      find_field_with_id(id, *field_types) ||
      flunk("Could not find field with id #{id.inspect}")
    end
    
    def find_field_labeled(label, *field_types) #:nodoc:
      forms.detect_mapped do |form|
        form.field_labeled(label, *field_types)
      end
    end
    
    def find_field_named(name, *field_types) #:nodoc:
      forms.detect_mapped do |form|
        form.field_named(name, *field_types)
      end
    end
    
    def find_field_with_id(id, *field_types) #:nodoc:
      forms.detect_mapped do |form|
        form.field_with_id(id, *field_types)
      end
    end
    
    def find_select_option(option_text, id_or_name_or_label) #:nodoc:
      if id_or_name_or_label
        field = field(id_or_name_or_label, SelectField)
        return field.find_option(option_text)
      else
        select_option = forms.detect_mapped do |form|
          form.find_select_option(option_text)
        end
        
        return select_option if select_option
      end
        
      flunk("Could not find option #{option_text.inspect}")
    end
    
    def find_button(value) #:nodoc:
      button = forms.detect_mapped do |form|
        form.find_button(value)
      end
      
      if button
        return button
      else
        flunk("Could not find button #{value.inspect}")
      end
    end
    
    def find_area(area_name) #:nodoc:
      areas.detect { |area| area.matches_text?(area_name) } ||
      flunk("Could not find area with name #{area_name}")
    end
    
    def find_link(text) #:nodoc:
      matching_links = links.select do |possible_link|
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