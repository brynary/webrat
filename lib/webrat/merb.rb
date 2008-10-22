module Webrat
  class Session
    include Merb::Test::RequestHelper
    
    attr_reader :response
    
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
    
    protected
    def do_request(url, data, headers, method)
      @response = request(url, :params => data, :headers => headers, :method => method)
      self.get(@response.headers['Location'], nil, @response.headers) if @response.status == 302
    end
    
  end
end

class Merb::Test::RspecStory
  def browser
    @browser ||= Webrat::Session.new
  end
end

