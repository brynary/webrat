require "webrat/rack"

module Webrat
  class SinatraSession < RackSession
    def initialize(context)
      app = context.respond_to?(:app) ? context.app : Sinatra::Application

      super(Rack::Test::Session.new(Rack::MockSession.new(app, "www.example.com")))
    end
  end
end
