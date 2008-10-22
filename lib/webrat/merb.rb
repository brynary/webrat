module Webrat
  class MerbSession < Session
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
      @response.code
    end
    
    protected
    def do_request(url, data, headers, method)
      all = (headers || {})
      all[:method] = method unless all[:method] || all["REQUEST_METHOD"]
      
      unless data.empty?
        if verb == "post"
          all[:body_params] = data
        elsif verb == "get"
          all[:params] = data
        end
      end
      
      @response = request(url, all)
      @response = self.get(@response.headers['Location'], nil, @response.headers) if @response.status == 302
    end
    
  end
end

class Merb::Test::RspecStory
  def browser
    @browser ||= Webrat::MerbSession.new
  end
end

