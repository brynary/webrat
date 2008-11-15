module Webrat
  module Core
    class Configuration
      
      # Configures Webrat. If this is not done, Webrat will be created
      # with all of the default settings. 
      def self.configure(configuration = Webrat::Core::Configuration.new)
        yield configuration if block_given?
        @@configuration = configuration
      end
      
      def self.configuration
        @@configuration = Webrat::Core::Configuration.new unless @@configuration
        @@configuration
      end
      
      # Sets whether to save and open pages with error status codes in a browser
      attr_accessor :open_error_files
      
      def initialize
        self.open_error_files = default_open_error_files
      end
      
      private
      @@configuration = nil
      
      def default_open_error_files
        true
      end
      
    end
  end
end