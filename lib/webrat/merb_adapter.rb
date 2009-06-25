require "webrat"
require "merb-core"
require "webrat/rack"

module Webrat
  class MerbAdapter < RackAdapter #:nodoc:
    def initialize(context=nil)
      app = context.respond_to?(:app) ?
        context.app : Merb::Rack::Application.new
      super(Rack::Test::Session.new(Rack::MockSession.new(app, "www.example.com")))
    end
  end
end

module Merb #:nodoc:
  module Test #:nodoc:
    module RequestHelper #:nodoc:
      def request(uri, env = {})
        @_webrat_session ||= Webrat::MerbAdapter.new
        @_webrat_session.response = @_webrat_session.request(uri, env)
      end
    end
  end
end
