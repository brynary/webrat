require "webrat/core"

require "cgi"
gem "extlib"
require "extlib"
require "merb-core"

HashWithIndifferentAccess = Mash

module Webrat
  class Session
    include Merb::Test::MakeRequest
    
    attr_accessor :response
    
    def get(url, data, headers = nil)
      do_request(url, data, headers, "GET")
    end
  
    def post(url, data, headers = nil)
      do_request(url, data, headers, "POST")
    end
  
    def put(url, data, headers = nil)
      do_request(url, data, headers, "PUT")
    end
  
    def delete(url, data, headers = nil)
      do_request(url, data, headers, "DELETE")
    end
    
    def response_body
      @response.body.to_s
    end
    
    def response_code
      @response.status
    end
    
    def do_request(url, data, headers, method)
      @response = request(url, 
        :params => (data && data.any?) ? data : nil, 
        :headers => headers, :method => method)
      self.get(@response.headers['Location'], nil, @response.headers) if @response.status == 302
    end
    
    def follow_redirect
      self.get(@response.headers['Location'], nil, @response.headers) if @response.status == 302
    end

  end
end

module Merb
  module Test
    module RequestHelper
      def request(uri, env = {})
        @session ||= Webrat::Session.new
        @session.response = @session.request(uri, env)
      end
  
      def follow_redirect
        @session.follow_redirect
      end
    end
  end
end

class Merb::Test::RspecStory
  def browser
    @browser ||= Webrat::Session.new
  end
end

