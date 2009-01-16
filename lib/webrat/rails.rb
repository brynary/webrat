require "webrat"

require "action_controller"
require "action_controller/integration"
require "action_controller/record_identifier"

module Webrat
  class RailsSession < Session #:nodoc:
    include ActionController::RecordIdentifier
    
    # The Rails version of within supports passing in a model and Webrat
    # will apply a scope based on Rails' dom_id for that model.
    #
    # Example:
    #   within User.last do
    #     click_link "Delete"
    #   end
    def within(selector_or_object, &block)
      if selector_or_object.is_a?(String)
        super
      else
        super('#' + dom_id(selector_or_object), &block)
      end
    end
    
    def doc_root
      File.expand_path(File.join(RAILS_ROOT, 'public'))
    end

    def saved_page_dir
      File.expand_path(File.join(RAILS_ROOT, "tmp"))
    end

    def get(url, data, headers = nil)
      do_request(:get, url, data, headers)
    end

    def post(url, data, headers = nil)
      do_request(:post, url, data, headers)
    end

    def put(url, data, headers = nil)
      do_request(:put, url, data, headers)
    end

    def delete(url, data, headers = nil)
      do_request(:delete, url, data, headers)
    end

    def response_body
      response.body
    end

    def response_code
      response.code.to_i
    end

    def xml_content_type?
      response.headers["Content-Type"].to_s =~ /xml/
    end

  protected

    def integration_session
      @context
    end

    #now that we are not following external links, do NOT normalize the url and strip it of its host
    #once we get here we don't care about stripping out the host because we know
    def do_request(http_method, url, data, headers) #:nodoc:
      update_protocol(url)
      integration_session.send(http_method, url, data, headers)
    end

    def update_protocol(href) #:nodoc:
      if href =~ /^https:/
        integration_session.https!(true)
      elsif href =~ /^http:/
        integration_session.https!(false)
      end
    end

    def response #:nodoc:
      integration_session.response
    end

  end
end

module ActionController #:nodoc:
  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Matchers
  end
end
