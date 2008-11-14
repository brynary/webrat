require "webrat/core/xml"
require "webrat/core/nokogiri"
require "webrat/core/logging"
require "webrat/core/flunk"
require "webrat/core/form"
require "webrat/core/scope"
require "webrat/core/link"
require "webrat/core/area"
require "webrat/core/label"
require "webrat/core/select_option"
require "webrat/core/session"
require "webrat/core/methods"
require "webrat/core/matchers"

module Webrat
  class Core
    
    # Configures Webrat. If this is not done, Webrat will be created
    # with all of the default settings. 
    # Example:
    #   Webrat::Core.configure do |config|
    #     config.open_error_files = false
    #   end
    def self.configure(configuration = Core.new)
      yield configuration if block_given?
      @@configuration = configuration
    end
    
    def self.configuration
      @@configuration = Core.new unless @@configuration
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