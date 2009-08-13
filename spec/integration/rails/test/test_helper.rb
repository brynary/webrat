ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

# begin
#   require "redgreen"
# rescue MissingSourceFile
# end

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../../../lib"
require "webrat"

Webrat.configure do |config|
  config.mode = ENV['WEBRAT_INTEGRATION_MODE'].to_sym
end

ActionController::Base.class_eval do
  def perform_action
    perform_action_without_rescue
  end
end
Dispatcher.class_eval do
  def self.failsafe_response(output, status, exception = nil)
    raise exception
  end
end
