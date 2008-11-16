require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  class WebratError < StandardError
  end

  VERSION = '0.3.2'
  
  def self.root #:nodoc:
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
  

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

  private
  @@configuration = nil

end

# We need Nokogiri's CSS to XPath support, even if using REXML and Hpricot for parsing and searching
require "nokogiri/css"

# Require nokogiri and fall back on rexml+Hpricot
begin
  require "nokogiri"
  require "webrat/core/nokogiri"
rescue LoadError => e
  require "hpricot"
  require "rexml/document"
end

require "webrat/core"

# TODO: This is probably not a good idea.
# Probably better for webrat users to require "webrat/rails" etc. directly
if defined?(RAILS_ENV)
  require "webrat/rails"
end
