require "webrat/core/locators/locator"

module Webrat
  module Locators

    class FieldByIdLocator < Locator # :nodoc:

      def locate
        Field.load(@session, field_element)
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
        Webrat::XML.xpath_search(@dom, *Field.xpath_search)
      end

      def error_message
        "Could not find field with id #{@value.inspect}"
      end

    end

    def field_with_id(id, *field_types)
      FieldByIdLocator.new(@session, dom, id, *field_types).locate!
    end

  end
end
