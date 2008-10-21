module Webrat
  class Session
    include Merb::Test::RequestHelper
    
    attr_reader :response
    
    def get(url, data, headers = nil)
<<<<<<< HEAD:lib/webrat/merb.rb
      @response = request(url, :params => data, :headers => headers, :method => "GET")
    end
  
    def post(url, data, headers = nil)
      @response = request(url, :params => data, :headers => headers, :method => "POST")
    end
  
    def put(url, data, headers = nil)
      @response = request(url, :params => data, :headers => headers, :method => "PUT")
    end
  
    def delete(url, data, headers = nil)
     @response = request(url, :params => data, :headers => headers, :method => "DELETE")
    end
    
    def response_body
      @response.body
=======
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
>>>>>>> 86879c13c05ad0448456575f148495bf700e1d4c:lib/webrat/merb.rb
    end
    
    def response_code
      @response.status
    end
    
<<<<<<< HEAD:lib/webrat/merb.rb
=======
    protected
    def do_request(url, data, headers, method)
      @response = request(url, :params => data, :headers => headers, :method => method)
      self.get(@response.headers['Location'], nil, @response.headers) if @response.status == 302
    end
    
>>>>>>> 86879c13c05ad0448456575f148495bf700e1d4c:lib/webrat/merb.rb
  end
end

class Merb::Test::RspecStory
  def browser
    @browser ||= Webrat::Session.new
  end
end

<<<<<<< HEAD:lib/webrat/merb.rb

# 
# class Application < Merb::Controller
#   def cookies=(newcookies)
#     @_cookies = newcookies
#   end
# end
# 
# 
# #Other utilities used by Webrat that are present in Rails but not Merb. We can require heavy dependencies
# #here because we're only loaded in Test mode. 
# require 'strscan'
# require 'cgi'
require File.join(File.dirname(__FILE__), "merb", "param_parser.rb")
require File.join(File.dirname(__FILE__), "merb", "url_encoded_pair_parser.rb")
# require File.join(File.dirname(__FILE__), "merb", "indifferent_access.rb")
# require File.join(File.dirname(__FILE__), "merb", "support.rb")
# 
# 
# 
=======
>>>>>>> 86879c13c05ad0448456575f148495bf700e1d4c:lib/webrat/merb.rb
