require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class AreaLocator < Locator
  
      def locate
        @scope.element_to_webrat_element(area_element)
      end
  
      def area_element
        area_elements.detect do |area_element|
          Webrat::XML.attribute(area_element, "title") =~ matcher ||
          Webrat::XML.attribute(area_element, "id") =~ matcher
        end
      end
  
      def matcher
        /#{Regexp.escape(@value.to_s)}/i
      end
  
      def area_elements
        Webrat::XML.css_search(@scope.dom, "area")
      end
  
    end
    
  end
end