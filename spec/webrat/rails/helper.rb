require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "active_support"

silence_warnings do
  require "action_controller"
  require "action_controller/integration"
end

require "webrat/rails"
