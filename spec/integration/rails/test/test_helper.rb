ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require "redgreen"

require File.dirname(__FILE__) + "/../../../../lib/webrat"

Webrat.configure do |config|
  mode = case ENV['WEBRAT_INTEGRATION_MODE']
    when 'webrat': :rails
    when 'selenium': :selenium
    else :rails
  end
  config.mode = mode
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