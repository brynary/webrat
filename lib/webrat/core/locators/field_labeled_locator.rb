require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FieldLabeledLocator < Locator
  
      def locate
        # TODO - Convert to using elements
        @scope.send(:forms).detect_mapped do |form|
          possible_fields = form.send(:fields_by_type, @field_types)
          
          matching_fields = possible_fields.select do |possible_field|
            possible_field.send(:labels).any? do |label|
              text(label.element) =~ /^\W*#{Regexp.escape(@value.to_s)}\b/i
            end
          end      
          
          matching_fields.min { |a, b| a.label_text.length <=> b.label_text.length }
        end
        
        # matching_fields.min { |a, b| a.label_text.length <=> b.label_text.length }
      end
      
      def matching_fields
        matching_labels.map(&:field).compact.uniq
      end
      
      def matching_labels
        matching_label_elements.map do |label_element|
          Label.load(@scope.session, label_element)
        end
      end
      
      def matching_label_elements
        label_elements.select do |label_element|
          text(label_element) =~ /^\W*#{Regexp.escape(@value.to_s)}\b/i
        end
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
      FieldLabeledLocator.new(self, label, *field_types).locate!
    end
    
  end
end