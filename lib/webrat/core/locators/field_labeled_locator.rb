require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FieldLabeledLocator < Locator
  
      def locate
        # TODO - Convert to using elements
        @scope.send(:forms).detect_mapped do |form|
          form.field_labeled(@value, *@field_types)
        end
      end
  
      def error_message
        "Could not find field labeled #{@value.inspect}"
      end
      
    end
    
    def field_labeled(label, *field_types)
      FieldLabeledLocator.new(self, label, *field_types).locate!
    end
    
  end
end