require "webrat/core/locators/locator"

module Webrat
  module Locators

    class FieldNamedLocator < Locator # :nodoc:

      def locate
        Field.load(@session, field_element)
      end

      def field_element
        field_elements.detect do |field_element|
          Webrat::XML.attribute(field_element, "name") == @value.to_s
        end
      end

      def field_elements
        Webrat::XML.xpath_search(@dom, *xpath_searches)
      end

      def xpath_searches
        if @field_types.any?
          @field_types.map { |field_type| field_type.xpath_search }.flatten
        else
          Array(Field.xpath_search)
        end
      end

      def error_message
        "Could not find field named #{@value.inspect}"
      end

    end

    def field_named(name, *field_types)
      FieldNamedLocator.new(@session, dom, name, *field_types).locate!
    end

  end
end
