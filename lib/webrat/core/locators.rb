require "webrat/core/locators/area_locator"
require "webrat/core/locators/button_locator"
require "webrat/core/locators/field_labeled_locator"
require "webrat/core/locators/label_locator"
require "webrat/core/locators/field_named_locator"
require "webrat/core/locators/field_by_id_locator"
require "webrat/core/locators/select_option_locator"
require "webrat/core/locators/link_locator"
require "webrat/core/locators/field_locator"
require "webrat/core/locators/form_locator"

module Webrat
  module Locators

    def field_by_xpath(xpath)
      Field.load(@session, Webrat::XML.xpath_at(dom, xpath))
    end

  end
end
