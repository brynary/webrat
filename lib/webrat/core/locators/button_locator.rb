require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class ButtonLocator < Locator # :nodoc:
  
      def locate
        ButtonField.load(@session, button_element)
      end
  
      def button_element
        button_elements.detect do |element|
          @value.nil?             ||
          matches_id?(element)    ||
          matches_value?(element) ||
          matches_html?(element)  ||
          matches_alt?(element)
        end
      end
  
      def matches_id?(element)
        (@value.is_a?(Regexp) && Webrat::XML.attribute(element, "id") =~ @value) ||
        (!@value.is_a?(Regexp) && Webrat::XML.attribute(element, "id") == @value.to_s)
      end
  
      def matches_value?(element)
        Webrat::XML.attribute(element, "value") =~ /^\W*#{Regexp.escape(@value.to_s)}/i
      end
  
      def matches_html?(element)
        Webrat::XML.inner_html(element) =~ /#{Regexp.escape(@value.to_s)}/i
      end
  
      def matches_alt?(element)
        Webrat::XML.attribute(element, "alt") =~ /^\W*#{Regexp.escape(@value.to_s)}/i
      end
  
      def button_elements
        Webrat::XML.xpath_search(@dom, *ButtonField.xpath_search)
      end
  
      def error_message
        "Could not find button #{@value.inspect}"
      end
      
    end
    
    def find_button(value) #:nodoc:
      ButtonLocator.new(@session, dom, value).locate!
    end
    
  end
end