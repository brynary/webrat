require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class SelectOptionLocator < Locator
  
      def initialize(scope, option_text, id_or_name_or_label)
        @scope = scope
        @option_text = option_text
        @id_or_name_or_label = id_or_name_or_label
      end
      
      def locate
        # TODO - Convert to using elements
        if @id_or_name_or_label
          field = @scope.field(@id_or_name_or_label, SelectField)
          field.find_option(@option_text)
        else
          @scope.send(:forms).detect_mapped do |form|
            form.find_select_option(@option_text)
          end
        end
      end
      
      def error_message
        if @id_or_name_or_label
          "The '#{@option_text}' option was not found in the #{@id_or_name_or_label.inspect} select box"
        else
          "Could not find option #{@option_text.inspect}"
        end
      end
  
    end
    
    def find_select_option(option_text, id_or_name_or_label) #:nodoc:
      SelectOptionLocator.new(self, option_text, id_or_name_or_label).locate!
    end
    
  end
end