require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class LabelLocator < Locator
  
      def locate
        # TODO - Convert to using elements

        @scope.send(:forms).detect_mapped do |form|
          form.label_matching(@value)
        end
      end
  
    end
    
  end
end