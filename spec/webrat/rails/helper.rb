require "active_support"

silence_warnings do
  require "action_controller"
  require "action_controller/integration"
end
require File.expand_path(File.dirname(__FILE__) + "/../../../lib/webrat/rails")
