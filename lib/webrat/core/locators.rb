require "webrat/core/locators/area_locator"
require "webrat/core/locators/button_locator"
require "webrat/core/locators/field_labeled_locator"
require "webrat/core/locators/label_locator"
require "webrat/core/locators/field_named_locator"
require "webrat/core/locators/field_by_id_locator"
require "webrat/core/locators/select_option_locator"
require "webrat/core/locators/link_locator"
require "webrat/core/locators/field_locator"

module Webrat
  module Locators
    
    def field_by_xpath(xpath)
      element_to_webrat_element(Webrat::XML.xpath_at(dom, xpath))
    end
    
    def element_to_webrat_element(element)
      return nil if element.nil?
      @session.elements[Webrat::XML.xpath_to(element)]
    end
    
  end
end
