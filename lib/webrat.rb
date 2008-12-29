require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  VERSION = '0.3.4'
  
  def self.root #:nodoc:
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
  
  def self.require_xml
    gem "nokogiri", ">= 1.1.0"
    
    # We need Nokogiri's CSS to XPath support, even if using
    # REXML and Hpricot for parsing and searching
    require "nokogiri"
    
    if on_java?
      require "hpricot"
      require "rexml/document"
    else
      require "webrat/core/nokogiri"
    end
  end
  
  def self.on_java?
    RUBY_PLATFORM =~ /java/
  end
end

Webrat.require_xml
require "webrat/core"

# TODO: This is probably not a good idea.
# Probably better for webrat users to require "webrat/rails" etc. directly
if defined?(RAILS_ENV)
  require "webrat/rails"
end
