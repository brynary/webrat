module Webrat
  module Locators
  
    class Locator # :nodoc:

      def initialize(session, dom, value, *field_types)
        @session = session
        @dom = dom
        @value = value
        @field_types = field_types
      end
  
      def locate!
        locate || raise(NotFoundError.new(error_message))
      end
      
    end
    
  end
end