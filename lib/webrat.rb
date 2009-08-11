require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  # The common base class for all exceptions raised by Webrat.
  class WebratError < StandardError
  end

  def self.require_xml
    if on_java?
      gem "nokogiri", ">= 1.2.4"
    else
      gem "nokogiri", ">= 1.0.6"
    end

    require "nokogiri"
    require "webrat/core/xml/nokogiri"
  end

  def self.on_java?
    RUBY_PLATFORM =~ /java/
  end

end

Webrat.require_xml

require "webrat/core"
