require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  class WebratError < StandardError
  end

  VERSION = '0.3.2'
  
  def self.root #:nodoc:
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end

end

if RUBY_PLATFORM =~ /java/
  # We need Nokogiri's CSS to XPath support, even if using REXML and Hpricot for parsing and searching
  require "nokogiri/css"
  require "hpricot"
  require "rexml/document"
else
  require "nokogiri"
  require "webrat/core/nokogiri"
end

require "webrat/core"

# TODO: This is probably not a good idea.
# Probably better for webrat users to require "webrat/rails" etc. directly
if defined?(RAILS_ENV)
  require "webrat/rails"
end
