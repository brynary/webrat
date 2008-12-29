require 'webrat/rack'
require 'sinatra'
require 'sinatra/test/methods'

disable :run
disable :reload

module Webrat
  class SinatraSession < RackSession #:nodoc:
    include Sinatra::Test::Methods
    
    attr_reader :request, :response

    %w(get head post put delete).each do |verb|
      define_method(verb) do |*args| # (path, data, headers = nil)
        path, data, headers = *args
        params = data.merge(:env => headers || {})
        self.__send__("#{verb}_it", path, params)
        get_it(@response.location, params) while @response.redirect?
      end
    end
  end
end
