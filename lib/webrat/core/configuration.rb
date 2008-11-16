module Webrat
  module Core
    class Configuration
      # Sets whether to save and open pages with error status codes in a browser
      attr_accessor :open_error_files
      
      def initialize
        self.open_error_files = default_open_error_files
      end
      
      private
      def default_open_error_files
        true
      end
      
    end
  end
end