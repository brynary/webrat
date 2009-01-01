require 'webrat/rack'
require 'sinatra'
require 'sinatra/test/methods'

class Sinatra::Application
  # Override this to prevent Sinatra from barfing on the options passed from RSpec
  def self.load_default_options_from_command_line!
  end
end

disable :run
disable :reload

module Webrat
  class SinatraSession < RackSession #:nodoc:
    include Sinatra::Test::Methods

    attr_reader :request, :response

    %w(get head post put delete).each do |verb|
      define_method(verb) do |*args| # (path, data, headers = nil)
        path, data, headers = *args
        data = data.inject({}) {|data, (key,value)| data[key] = Rack::Utils.unescape(value); data }
        params = data.merge(:env => headers || {})
        self.__send__("#{verb}_it", path, params)
      end
    end
  end
end
