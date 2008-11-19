require "webrat/core_extensions/detect_mapped"

module Webrat
  module Locators

    def field(*args)
      # This is the default locator strategy
      find_field_with_id(*args) ||
      find_field_named(*args)   ||
      field_labeled(*args)      ||
      raise(NotFoundError.new("Could not find field: #{args.inspect}"))
    end
    
    def field_labeled(label, *field_types)
      find_field_labeled(label, *field_types) ||
      raise(NotFoundError.new("Could not find field labeled #{label.inspect}"))
    end

    def field_named(name, *field_types)
      find_field_named(name, *field_types) ||
      raise(NotFoundError.new("Could not find field named #{name.inspect}"))
    end
    
    def field_with_id(id, *field_types)
      find_field_with_id(id, *field_types) ||
      raise(NotFoundError.new("Could not find field with id #{id.inspect}"))
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
        
      raise NotFoundError.new("Could not find option #{option_text.inspect}")
    end
    
    def find_button(value) #:nodoc:
      button = forms.detect_mapped do |form|
        form.find_button(value)
      end
      
      if button
        return button
      else
        raise NotFoundError.new("Could not find button #{value.inspect}")
      end
    end
    
    def find_area(area_name) #:nodoc:
      areas.detect { |area| area.matches_text?(area_name) } ||
      raise(NotFoundError.new("Could not find area with name #{area_name}"))
    end
    
    def find_link(text_or_title_or_id) #:nodoc:
      matching_links = links.select do |possible_link|
        possible_link.matches_text?(text_or_title_or_id) || possible_link.matches_id?(text_or_title_or_id)
      end

      if matching_links.any?
        matching_links.min { |a, b| a.text.length <=> b.text.length }
      else
        raise NotFoundError.new("Could not find link with text or title or id #{text_or_title_or_id.inspect}")
      end
    end

    def find_field_id_for_label(label_text)
      label = forms.detect_mapped { |form| form.label_matching(label_text) } 
      if label
        label.for_id
      else
        raise NotFoundError.new("Could not find the label with text #{label_text}")
      end
    end
    
  end
end
