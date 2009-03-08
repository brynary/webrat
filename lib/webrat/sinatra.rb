require "webrat/rack"
require "sinatra/test"

module Webrat
  class SinatraSession < RackSession
    include Sinatra::Test

    attr_reader :request, :response

    def initialize(context = nil)
      super(context)

      app = context.respond_to?(:app) ? context.app : Sinatra::Application
      @browser = Sinatra::TestHarness.new(app)
    end

    %w(get head post put delete).each do |verb|
      class_eval <<-RUBY
        def #{verb}(path, data, headers = {})
          params = data.inject({}) do |data, (key,value)|
            data[key] = Rack::Utils.unescape(value)
            data
          end
          headers["HTTP_HOST"] = "www.example.com"
          @browser.#{verb}(path, params, headers)
        end
      RUBY
    end

    def response_body
      @browser.body
    end

    def response_code
      @browser.status
    end

    private

      def response
        @browser.response
      end
  end
end
