require 'webrat/rack/rack_session'
require 'sinatra'
require 'sinatra/test/methods'

module Webrat
  class SinatraSession < RackSession
    include Sinatra::Test::Methods

    def get(*args)
      get_it(*args)
    end
  end
end