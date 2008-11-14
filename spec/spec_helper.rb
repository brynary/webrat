require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")
require File.expand_path(File.dirname(__FILE__) + "/fakes/test_session")

Spec::Runner.configure do |config|
  # Nothing to configure yet
end


class Webrat::Core
  @@previous_config = nil
  
  def self.cache_config_for_test
    @@configuration = Webrat::Core.configuration
  end
  
  def self.reset_for_test
    @@configuration = @@previous_config if @@previous_config
  end
end