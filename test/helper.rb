require "rubygems"
require "test/unit"
# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end
require "mocha"


require "active_support"

silence_warnings do
  require "action_controller"
  require "action_controller/integration"
end

require File.expand_path(File.dirname(__FILE__) + "/../lib/webrat")

class ActionController::Integration::Session
  def flunk(message)
    raise message
  end
end