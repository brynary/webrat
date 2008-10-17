require 'webrat/rack/rack_session'
require 'sinatra'
require 'sinatra/test/methods'

module Webrat
  class SinatraSession < RackSession
    include Sinatra::Test::Methods

    %w(get head post put delete).each do |verb|
      define_method(verb) do |*args|
        url, data, headers = *args
        self.__send__("#{verb}_it", url, data)
        follow! while @response.redirect?
      end
    end
  end
end