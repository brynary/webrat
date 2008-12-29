require "webrat"

require "action_controller"
require "action_controller/integration"

module Webrat
  class RailsSession < Session #:nodoc:

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

    def do_request(http_method, url, data, headers) #:nodoc:
      update_protocol(url)

      integration_session.send(http_method, normalize_url(url), data, headers)
      integration_session.follow_redirect_with_headers(headers) while integration_session.internal_redirect?
      integration_session.status
    end

    # remove protocol, host and anchor
    def normalize_url(href) #:nodoc:
      uri = URI.parse(href)
      normalized_url = uri.path
      if uri.query
        normalized_url += "?" + uri.query
      end
      normalized_url
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
  module Integration #:nodoc:
    class Session #:nodoc:
      def internal_redirect?
        redirect? && response.redirect_url_match?(host)
      end

      def follow_redirect_with_headers(h = {})
        raise "Not a redirect! #{@status} #{@status_message}" unless redirect?

        h['HTTP_REFERER'] = request.url

        location = headers["location"]
        location = location.first if location.is_a?(Array)
        
        get(location, {}, h)
        status
      end
    end
  end

  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Matchers
  end
end
