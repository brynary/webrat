require "rubygems"
require "spec"
require "spec/interop/test"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")
require File.dirname(__FILE__) + "/fakes/test_session"

if ["rails","merb"].include?(ENV["TEST_MODE"])
  require File.join(File.dirname(__FILE__), "webrat", "#{ENV["TEST_MODE"]}", "helper.rb")
else
  puts "Assuming test mode is Rails... for Merb set TEST_MODE=merb and rerun."
  ENV["TEST_MODE"] = 'rails'
  require File.join(File.dirname(__FILE__), "webrat", "#{ENV["TEST_MODE"]}", "helper.rb")
end



Spec::Runner.configure do |config|
  # Nothing to configure yet
end