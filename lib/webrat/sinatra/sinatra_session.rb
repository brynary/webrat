require 'webrat/rack/rack_session'
require 'sinatra'
require 'sinatra/test/methods'

module Webrat
  class SinatraSession < RackSession
    include Sinatra::Test::Methods

    def get(url, data, headers = nil)
      get_it(url, data)
    end

    def post(url, data, headers = nil)
      post_it(url, data)
    end
  end
end