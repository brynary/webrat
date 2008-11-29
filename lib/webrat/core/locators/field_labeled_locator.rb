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
  
    end
    
  end
end