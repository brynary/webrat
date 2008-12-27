module Webrat
  
  # Configures Webrat. If this is not done, Webrat will be created
  # with all of the default settings. 
  def self.configure(configuration = Webrat::Configuration.new)
    yield configuration if block_given?
    @@configuration = configuration
  end
      
  def self.configuration # :nodoc:
    @@configuration ||= Webrat::Configuration.new
  end

  # Webrat can be configured using the Webrat.configure method. For example:
  # 
  #   Webrat.configure do |config|
  #     config.parse_with_nokogiri = false
  #   end
  class Configuration
    
    # Should XHTML be parsed with Nokogiri? Defaults to true, except on JRuby. When false, Hpricot and REXML are used
    attr_writer :parse_with_nokogiri
    
    # Webrat's mode, set automatically when requiring webrat/rails, webrat/merb, etc.
    attr_accessor :mode # :nodoc:
    
    # Save and open pages with error status codes (500-599) in a browser? Defualts to true.
    attr_writer :open_error_files
    
    # Which environment should the selenium tests be run in? Defaults to selenium.
    attr_accessor :selenium_environment

    # Which port should the selenium tests be run on? Defaults to 3001.
    attr_accessor :selenium_port

    def initialize # :nodoc:
      self.open_error_files = true
      self.parse_with_nokogiri = !Webrat.on_java?
      self.selenium_environment = :selenium
      self.selenium_port = 3001
    end
    
    def parse_with_nokogiri? #:nodoc:
      @parse_with_nokogiri ? true : false
    end
    
    def open_error_files? #:nodoc:
      @open_error_files ? true : false
    end
    
    # Allows setting of webrat's mode, valid modes are:
    # :rails, :selenium, :rack, :sinatra, :mechanize, :merb
    def mode=(mode)
      @mode = mode
      require("webrat/#{mode}")
    end
    
  end
  
end