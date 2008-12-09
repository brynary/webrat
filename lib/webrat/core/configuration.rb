module Webrat
  
  # Configures Webrat. If this is not done, Webrat will be created
  # with all of the default settings. 
  def self.configure(configuration = Webrat::Configuration.new)
    yield configuration if block_given?
    @@configuration = configuration
  end
      
  def self.configuration
    @@configuration ||= Webrat::Configuration.new
  end
  
  class Configuration
    
    RAILS_MODE = :rails
    SELENIUM_MODE = :selenium
    RACK_MODE = :rack
    SINATRA_MODE = :sinatra
    MECHANIZE_MODE = :mechanize
    MERB_MODE = :merb
    
    # Should XHTML be parsed with Nokogiri? Defaults to true, except on JRuby. When false, Hpricot and REXML are used
    attr_writer :parse_with_nokogiri
    
    # Webrat's mode, set automatically when requiring webrat/rails, webrat/merb, etc.
    attr_accessor :mode
    
    # Save and open pages with error status codes (500-599) in a browser? Defualts to true.
    attr_writer :open_error_files
    
    def initialize # :nodoc:
      self.open_error_files = true
      self.parse_with_nokogiri = !Webrat.on_java?
    end
    
    def parse_with_nokogiri? #:nodoc:
      @parse_with_nokogiri ? true : false
    end
    
    def open_error_files? #:nodoc:
      @open_error_files ? true : false
    end
    
    # Allows setting of webrat's mode, valid modes are:
    # RAILS_MODE - Used in typical rails development
    # SELENIUM_MODE - Used for webrat in selenium mode
    def mode=(mode)
      @mode = mode
      require("webrat/#{mode}")
    end
    
  end
  
end