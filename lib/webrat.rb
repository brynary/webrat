module Webrat
  VERSION = '0.2.2'
  def self.root
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
end

require "rubygems"
require "active_support"

require File.dirname(__FILE__) + "/webrat/core"
require File.dirname(__FILE__) + "/webrat/rails" if defined?(RAILS_ENV)
require File.join(File.dirname(__FILE__), "boot_merb.rb") if defined?(Merb)
