require "rubygems"
require "test/unit"
require "mocha"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

if ["rails","merb"].include?(ENV["TEST_MODE"])
  require File.join(File.dirname(__FILE__), "helper_#{ENV["TEST_MODE"]}.rb")
else
  raise "Please set the environment variable TEST_MODE to either 'rails' or 'merb'."
end
  
require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")

def test_session
  return ActionController::Integration::Session.new if ENV["TEST_MODE"] == "rails"
  return Merb::Test::RspecStory.new if ENV["TEST_MODE"] == "merb"
  raise "Unknown test type #{ENV["TEST_MODE"]}"
end