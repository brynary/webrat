require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  VERSION = '0.3.2'
  
  def self.root #:nodoc:
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
  
  class WebratError < StandardError
  end
end

# We need Nokogiri's CSS to XPath support, even if using REXML
require "nokogiri/css"

# Require nokogiri and fall back on rexml
begin
  require "nokogiri"
  require "webrat/core/nokogiri"
rescue LoadError => e
  require "rexml/document"
  warn("Standard REXML library is slow. Please consider installing nokogiri.\nUse \"sudo gem install nokogiri\"")
end

require "webrat/core"

# TODO: This is probably not a good idea.
# Probably better for webrat users to require "webrat/rails" etc. directly
if defined?(RAILS_ENV)
  require "webrat/rails"
end
