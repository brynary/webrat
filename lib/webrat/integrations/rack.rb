if defined?(ActionController::IntegrationTest)
  module ActionController #:nodoc:
    IntegrationTest.class_eval do
      include Rack::Test::Methods
      include Webrat::Methods
      include Webrat::Matchers
    end
  end
end
