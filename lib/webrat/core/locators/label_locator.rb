require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class LabelLocator < Locator # :nodoc:
  
      def locate
        Label.load(@session, label_element)
      end
      
      def label_element
        label_elements.detect do |label_element|
          text(label_element) =~ /^\W*#{Regexp.escape(@value.to_s)}\b/i
        end
      end
  
      def label_elements
        Webrat::XML.xpath_search(@dom, Label.xpath_search)
      end
      
      def text(label_element)
        str = Webrat::XML.all_inner_text(label_element)
        str.gsub!("\n","")
        str.strip!
        str.squeeze!(" ")
        str
      end
      
    end
    
  end
end