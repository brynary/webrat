require "webrat/core/locators/locator"

module Webrat
  module Locators

    class AreaLocator < Locator # :nodoc:

      def locate
        Area.load(@session, area_element)
      end

      def area_element
        area_elements.detect do |area_element|
          area_element["title"] =~ matcher ||
          area_element["id"] =~ matcher
        end
      end

      def matcher
        /#{Regexp.escape(@value.to_s)}/i
      end

      def area_elements
        @dom.xpath(*Area.xpath_search)
      end

      def error_message
        "Could not find area with name #{@value}"
      end

    end

    def find_area(id_or_title) #:nodoc:
      AreaLocator.new(@session, dom, id_or_title).locate!
    end

  end
end
