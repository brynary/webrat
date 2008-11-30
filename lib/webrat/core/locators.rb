require "webrat/core_extensions/detect_mapped"

require "webrat/core/locators/area_locator"
require "webrat/core/locators/button_locator"
require "webrat/core/locators/field_labeled_locator"
require "webrat/core/locators/label_locator"
require "webrat/core/locators/field_named_locator"
require "webrat/core/locators/field_by_id_locator"
require "webrat/core/locators/select_option_locator"
require "webrat/core/locators/link_locator"

module Webrat
  module Locators
    
    def field_by_xpath(xpath)
      element_to_webrat_element(Webrat::XML.xpath_at(dom, xpath))
    end
    
    def element_to_webrat_element(element)
      return nil if element.nil?
      @session.elements[Webrat::XML.xpath_to(element)]
    end
    
    def field(*args) # :nodoc:
      # This is the default locator strategy
      FieldByIdLocator.new(self, args.first).locate ||
      FieldNamedLocator.new(self, *args).locate   ||
      FieldLabeledLocator.new(self, *args).locate      ||
      raise(NotFoundError.new("Could not find field: #{args.inspect}"))
    end
    
  end
end
