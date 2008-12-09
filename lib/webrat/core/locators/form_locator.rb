require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FormLocator < Locator # :nodoc:
  
      def locate
        Form.load(@session, form_element)
      end
      
      def form_element
        Webrat::XML.css_at(@dom, "#" + @value)
      end
      
    end
    
  end
end