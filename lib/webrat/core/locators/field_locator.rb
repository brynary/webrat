require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class FieldLocator < Locator
  
      def locate
        FieldByIdLocator.new(@scope, @value).locate   ||
        FieldNamedLocator.new(@scope, @value, *@field_types).locate   ||
        FieldLabeledLocator.new(@scope, @value, *@field_types).locate
      end
  
    end
    
  end
end