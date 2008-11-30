module Webrat
  module Locators
  
    class Locator
  
      def initialize(scope, value, *field_types)
        @scope = scope
        @value = value
        @field_types = field_types
      end
  
      def locate!
        locate || raise(NotFoundError.new(error_message))
      end
      
    end
    
  end
end