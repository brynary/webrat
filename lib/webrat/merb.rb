module Webrat
  module MerbTest

    #Our own redirect actions defined below, to deal with the fact that we need to store
    #a controller reference.

    def current_page
      @current_page ||= Webrat::Page.new(self)
    end

    def current_page=(new_page)
      @current_page = new_page
    end

    # Issues a GET request for a page, follows any redirects, and verifies the final page
    # load was successful.
    #
    # Example:
    #   visits "/"
    def visits(*args)
      @current_page = Webrat::Page.new(self, *args)
    end

    def save_and_open_page
      current_page.save_and_open
    end

    [:reloads, :fills_in, :clicks_button, :selects, :chooses, :checks, :unchecks, :clicks_link, :clicks_link_within, :clicks_put_link, :clicks_get_link, :clicks_post_link, :clicks_delete_link].each do |method_name|
      define_method(method_name) do |*args|
        current_page.send(method_name, *args)
      end
    end

    #Session defines the following (used by webrat), but RspecStory doesn't. Merb's get/put/delete return a controller,
    #which is where we get our status and response from. 
    #
    #We have to preserve cookies like this, or the session is lost.
    #
    #While (in a web application) a PUT is modelled as a POST with a parameter _method, 
    #this close to the metal we need to make sure that we actually hit the underlying 'put' method,
    #so we rewrite 'method'.
    def request_via_redirect(method,path,parameters={},headers={})
      method = parameters["_method"] if !parameters["_method"].blank?
      mycookies = defined?(@controller) ? @controller.cookies : nil #will be nil if no requests yet
      begin
        @controller=self.send(method, path, parameters, headers) do |new_controller|
          new_controller.cookies = mycookies
        end
      rescue => exception
        raise unless exception.kind_of?(Merb::ControllerExceptions::Base)
        #Now we want to go one level below 'post' to build the request ourselves, then send it to the controller
        exception_klass = exception.class
        klass = ::Exceptions rescue Merb::Controller
        request = fake_request
        request.params[:exception] = exception
        request.params[:action] = exception_klass.name
        @controller=dispatch_request(request, klass, exception_klass.name)
      end
  
      follow_redirect! while redirect?
      status
    end

    def get_via_redirect(path, parameters = {}, headers = {})
      request_via_redirect(:get,path,parameters,headers)
    end

    def put_via_redirect(path, parameters = {}, headers = {})
      request_via_redirect(:put,path,parameters,headers)
    end

    def post_via_redirect(path, parameters = {}, headers = {})
      request_via_redirect(:post,path,parameters,headers)
    end  

    def delete_via_redirect(path, parameters = {}, headers = {})
      request_via_redirect(:delete,path,parameters,headers)
    end  

    def follow_redirect!
      mycookies = @controller.cookies rescue nil
      @controller=get @controller.headers["Location"] do |new_controller|
        new_controller.cookies=mycookies
      end
    end

    def redirect?
      [307, *(300..305)].include?(status)
    end

    def status
      @controller.status
    end

    def response
      @controller #things like @controller.body will work.
    end

    def assert_response(resp)
      if resp == :success
        response.should be_successful
      else
        raise "assert_response #{resp.inspect} is not supported"
      end
    end 

  end
end

class Application < Merb::Controller
  def cookies=(newcookies)
    @_cookies = newcookies
  end
end


#Other utilities used by Webrat that are present in Rails but not Merb. We can require heavy dependencies
#here because we're only loaded in Test mode. 
require 'strscan'
require 'cgi'
require File.join(File.dirname(__FILE__), "merb", "param_parser.rb")
require File.join(File.dirname(__FILE__), "merb", "url_encoded_pair_parser.rb")
require File.join(File.dirname(__FILE__), "merb", "indifferent_access.rb")
require File.join(File.dirname(__FILE__), "merb", "support.rb")



