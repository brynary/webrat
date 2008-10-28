require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

module Webrat
  VERSION = '0.2.2'
  
  def self.root
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
end

# require "webrat/merb/param_parser"
# require "webrat/merb/url_encoded_pair_parser"
require "webrat/core"

require "webrat/rails"  if defined?(RAILS_ENV)
require "webrat/merb"   if defined?(Merb)
