#In Merb, we have an RspecStory instead of an integration Session. 
class Merb::Test::RspecStory

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
  def get_via_redirect(path, parameters = {}, headers = {})
    @controller=get path, parameters, headers
    follow_redirect! while redirect?
    status
  end
  def put_via_redirect(path, parameters = {}, headers = {})
    @controller=put path, parameters, headers
    follow_redirect! while redirect?
    status
  end
  def delete_via_redirect(path, parameters = {}, headers = {})
    @controller=delete path, parameters, headers
    follow_redirect! while redirect?
    status
  end  
  
  def follow_redirect!
    @controller=get @controller.headers["Location"]
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

#Other utilities used by Webrat that are present in Rails but not Merb. We can require heavy dependencies
#here because we're only loaded in Test mode. 
require 'strscan'
require 'cgi'
require File.join(File.dirname(__FILE__), "merb_support", "param_parser.rb")
require File.join(File.dirname(__FILE__), "merb_support", "url_encoded_pair_parser.rb")
require File.join(File.dirname(__FILE__), "merb_support", "indifferent_access.rb")

