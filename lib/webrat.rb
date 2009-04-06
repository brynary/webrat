require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  # The common base class for all exceptions raised by Webrat.
  class WebratError < StandardError
  end

  VERSION = '0.4.4'

  def self.require_xml
    gem "nokogiri", ">= 1.0.6"
    
    if on_java?
      # We need Nokogiri's CSS to XPath support, even if using REXML and Hpricot for parsing and searching
      require "nokogiri/css"
      require "hpricot"
      require "rexml/document"
    else
      require "nokogiri"
      require "webrat/core/xml/nokogiri"
    end
  end
  
  def self.on_java?
    RUBY_PLATFORM =~ /java/
  end
  
end

Webrat.require_xml

require "webrat/core"
