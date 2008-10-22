module Webrat
  VERSION = '0.2.2'
  def self.root
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
end

require "rubygems"

require File.dirname(__FILE__) + "/webrat/core"
require File.dirname(__FILE__) + "/webrat/rails" if defined?(RAILS_ENV)
require File.dirname(__FILE__) + "/webrat/merb" if defined?(Merb)
