require "webrat/core/locators/locator"

class FieldByIdLocator < Locator
  
  def locate
    @scope.field_by_element(field_element)
  end
  
  def field_element
    field_elements.detect do |field_element|
      if @value.is_a?(Regexp)
        Webrat::XML.attribute(field_element, "id") =~ @value
      else
        Webrat::XML.attribute(field_element, "id") == @value.to_s
      end
    end
  end
  
  def field_elements
    Webrat::XML.xpath_search(@scope.dom, *Webrat::Field.xpath_search)
  end
  
end