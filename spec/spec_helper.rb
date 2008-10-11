require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

if ["rails","merb"].include?(ENV["TEST_MODE"])
  require File.join(File.dirname(__FILE__), "helper_#{ENV["TEST_MODE"]}.rb")
else
  raise "Please set the environment variable TEST_MODE to either 'rails' or 'merb'."
end
  
require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")
require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat/rails")
require File.dirname(__FILE__) + "/fakes/test_session"

Spec::Runner.configure do |config|
  # Nothing to configure yet
end