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
      require "webrat/core/locators/field_labeled_locator"
      
      FieldLabeledLocator.new(self, label, *field_types).locate
    end
    
    def find_field_named(name, *field_types) #:nodoc:
      require "webrat/core/locators/field_named_locator"
      
      FieldNamedLocator.new(self, name, *field_types).locate
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
      require "webrat/core/locators/select_option_locator"
      
      option = SelectOptionLocator.new(self, option_text, id_or_name_or_label).locate
      return option if option
      
      if id_or_name_or_label
        select_box_text = " in the #{id_or_name_or_label.inspect} select box"
        raise NotFoundError.new("The '#{option_text}' option was not found#{select_box_text}") 
      else
        raise NotFoundError.new("Could not find option #{option_text.inspect}")
      end
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
      require "webrat/core/locators/label_locator"
      
      if (label = LabelLocator.new(self, label_text).locate)
        label.for_id
      else
        raise NotFoundError.new("Could not find the label with text #{label_text}")
      end
    end
    
  end
end
