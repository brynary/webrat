require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FormLocator < Locator
  
      def locate
        Form.load(@scope.session, form_element)
      end
      
      def form_element
        Webrat::XML.css_at(@scope.dom, "#" + @value)
      end
      
    end
    
  end
end