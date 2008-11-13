require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")
require File.expand_path(File.dirname(__FILE__) + "/fakes/test_session")

Spec::Runner.configure do |config|
  # Nothing to configure yet
end