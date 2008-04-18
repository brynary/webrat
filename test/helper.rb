require "rubygems"
require "test/unit"
require "mocha"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

if ENV["TEST_MODE"] == "rails"
  require "active_support"
  silence_warnings do
    require "action_controller"
    require "action_controller/integration"
  end

  class ActionController::Integration::Session
    def flunk(message)
      raise message
    end
  end

elsif ENV["TEST_MODE"] == "merb"
  require 'merb-core'
  require 'merb_stories'
  #require 'spec'  #makes mocha cry
  module Merb
    module Test
      class RspecStory
        include Merb::Test::ControllerHelper
        include Merb::Test::RouteHelper
        include Merb::Test::ViewHelper
      end
   end
  end
  
else
  raise "Please set the environment variable TEST_MODE to either 'rails' or 'merb'."
end

require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")
