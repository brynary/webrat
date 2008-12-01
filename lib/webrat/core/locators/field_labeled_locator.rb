require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FieldLabeledLocator < Locator # :nodoc:
  
      def locate
        matching_labels.any? && matching_labels.first.field
      end
      
      def matching_labels
        matching_label_elements.sort_by do |label_element|
          text(label_element).length
        end.map do |label_element|
          Label.load(@session, label_element)
        end
      end
      
      def matching_label_elements
        label_elements.select do |label_element|
          text(label_element) =~ /^\W*#{Regexp.escape(@value.to_s)}\b/i
        end
      end
      
      def label_elements
        Webrat::XML.xpath_search(@dom, Label.xpath_search)
      end
  
      def error_message
        "Could not find field labeled #{@value.inspect}"
      end
      
      def text(element)
        str = Webrat::XML.all_inner_text(element)
        str.gsub!("\n","")
        str.strip!
        str.squeeze!(" ")
        str
      end
      
    end
    
    def field_labeled(label, *field_types)
      FieldLabeledLocator.new(@session, dom, label, *field_types).locate!
    end
    
  end
end