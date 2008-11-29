require "webrat/core/locators/locator"

class FieldNamedLocator < Locator
  
  def locate
    @scope.field_by_element(field_element)
  end
  
  def field_element
    field_elements.detect do |field_element|
      Webrat::XML.attribute(field_element, "name") == @value.to_s
    end
  end
  
  def field_elements
    Webrat::XML.xpath_search(@scope.dom, *xpath_searches)
  end
  
  def xpath_searches
    if @field_types.any?
      @field_types.map { |field_type| field_type.xpath_search }.flatten
    else
      Array(Field.xpath_search)
    end
  end
  
end