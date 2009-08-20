require "webrat/selenium"

if defined?(ActionController::IntegrationTest)
  module ActionController #:nodoc:
    IntegrationTest.class_eval do
      include Webrat::Methods
      include Webrat::Selenium::Methods
      include Webrat::Selenium::Matchers
    end
  end
end