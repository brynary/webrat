require "webrat/core_extensions/detect_mapped"

module Webrat
  module Locators
    
    def field_by_xpath(xpath)
      field_by_element(Webrat::XML.xpath_at(dom, xpath))
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
      # TODO - Convert to using elements
      forms.detect_mapped do |form|
        form.field_labeled(label, *field_types)
      end
    end
    
    def find_field_named(name, *field_types) #:nodoc:
      if field_types.any?
        xpath_searches = field_types.map { |field_type| field_type.xpath_search }.flatten
        field_elements = Webrat::XML.xpath_search(dom, xpath_searches)
      else
        field_elements = Webrat::XML.xpath_search(dom, *Field.xpath_search)
      end
      
      field_element = field_elements.detect do |field_element|
        Webrat::XML.attribute(field_element, "name") == name.to_s
      end
      
      field_by_element(field_element)
    end
    
    def field_by_element(element)
      return nil if element.nil?
      @session.elements[Webrat::XML.xpath_to(element)]
    end
    
    def area_by_element(element)
      return nil if element.nil?
      @session.elements[Webrat::XML.xpath_to(element)]
    end
    
    def link_by_element(element)
      return nil if element.nil?
      @session.elements[Webrat::XML.xpath_to(element)]
    end
    
    def find_field_with_id(id, *field_types) #:nodoc:
      require "webrat/core/locators/field_by_id_locator"
      
      FieldByIdLocator.new(self, id).locate
    end
    
    def find_select_option(option_text, id_or_name_or_label) #:nodoc:
      # TODO - Convert to using elements
      
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
      require "webrat/core/locators/button_locator"
      
      ButtonLocator.new(self, value).locate ||
      raise(NotFoundError.new("Could not find button #{value.inspect}"))
    end
    
    def find_area(id_or_title) #:nodoc:
      require "webrat/core/locators/area_locator"
      
      AreaLocator.new(self, id_or_title).locate ||
      raise(NotFoundError.new("Could not find area with name #{id_or_title}"))
    end
    
    def find_link(text_or_title_or_id) #:nodoc:
      require "webrat/core/locators/link_locator"
      
      LinkLocator.new(self, text_or_title_or_id).locate ||
      raise(NotFoundError.new("Could not find link with text or title or id #{text_or_title_or_id.inspect}"))
    end

    def find_field_id_for_label(label_text) #:nodoc:
      # TODO - Convert to using elements
      
      label = forms.detect_mapped { |form| form.label_matching(label_text) } 
      if label
        label.for_id
      else
        raise NotFoundError.new("Could not find the label with text #{label_text}")
      end
    end
    
  end
end
