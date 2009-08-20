require "webrat/integrations/merb"

module Webrat
  class MerbAdapter < RackAdapter #:nodoc:
    def initialize(context=nil)
      app = context.respond_to?(:app) ?
        context.app : Merb::Rack::Application.new
      super(Rack::Test::Session.new(Rack::MockSession.new(app, "www.example.com")))
    end
  end
end
