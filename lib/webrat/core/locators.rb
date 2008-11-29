require "webrat/core_extensions/detect_mapped"

module Webrat
  module Locators

    def field_by_xpath(xpath)
      element = Webrat::XML.xpath_search(dom, xpath).first
      
      forms.detect_mapped do |form|
        form.field_by_element(element)
      end
    end
    
    def field(*args) # :nodoc:
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
    
    def field_by_element(element, *field_types)
      forms.detect_mapped do |form|
        form.field_by_element(element, *field_types)
      end
    end
    
    def area_by_element(element)
      return nil if element.nil?
      
      expected_path = Webrat::XML.xpath_to(element)
      
      areas.detect do |possible_area|
        possible_area.path == expected_path
      end
    end
    
    def find_field_with_id(id, *field_types) #:nodoc:
      field_elements = Webrat::XML.css_search(dom, "button", "input", "textarea", "select")
      
      field_element = field_elements.detect do |field_element|
        if id.is_a?(Regexp)
          Webrat::XML.attribute(field_element, "id") =~ id
        else
          Webrat::XML.attribute(field_element, "id") == id.to_s
        end
      end
      
      field_by_element(field_element)
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
      field_elements = Webrat::XML.css_search(dom, "button", "input[type=submit]", "input[type=image]")
      
      field_element = field_elements.detect do |field_element|
        value.nil? ||
        (value.is_a?(Regexp) && Webrat::XML.attribute(field_element, "id") =~ value) ||
        (!value.is_a?(Regexp) && Webrat::XML.attribute(field_element, "id") == value.to_s) ||
        Webrat::XML.attribute(field_element, "value") =~ /^\W*#{Regexp.escape(value.to_s)}/i ||
        Webrat::XML.inner_html(field_element) =~ /#{Regexp.escape(value.to_s)}/i ||
        Webrat::XML.attribute(field_element, "alt") =~ /^\W*#{Regexp.escape(value.to_s)}/i
      end
      
      button = field_by_element(field_element)
      
      if button
        return button
      else
        raise NotFoundError.new("Could not find button #{value.inspect}")
      end
    end
    
    def find_area(id_or_title) #:nodoc:
      area_elements = Webrat::XML.css_search(dom, "area")
      
      matcher = /#{Regexp.escape(id_or_title.to_s)}/i
      
      area_element = area_elements.detect do |area_element|
        Webrat::XML.attribute(area_element, "title") =~ matcher ||
        Webrat::XML.attribute(area_element, "id") =~ matcher
      end
      
      area_by_element(area_element) ||
      raise(NotFoundError.new("Could not find area with name #{id_or_title}"))
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

    def find_field_id_for_label(label_text) #:nodoc:
      label = forms.detect_mapped { |form| form.label_matching(label_text) } 
      if label
        label.for_id
      else
        raise NotFoundError.new("Could not find the label with text #{label_text}")
      end
    end
    
  end
end
