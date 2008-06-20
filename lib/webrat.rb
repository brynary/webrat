module Webrat
  VERSION = '0.2.1'
end

require "rubygems"
require "active_support"

require File.dirname(__FILE__) + "/webrat/core"
require File.dirname(__FILE__) + "/webrat/rails" if defined?(RAILS_ENV)
