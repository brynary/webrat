require "webrat"

require "cgi"
gem "extlib"
require "extlib"
require "merb-core"

begin
  # Require Merb::Test::MultipartRequestHelper with multipart support.
  require "merb-core/two-oh"
rescue LoadError => e
  # Maybe Merb got rid of this. We'll do more checking for multiparth support.
end

# HashWithIndifferentAccess = Mash

module Webrat
  class MerbSession < Session #:nodoc:
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

    include Merb::Test::MultipartRequestHelper

    def do_request(url, data, headers, method)
      if method == "POST" && supports_multipart? && has_file?(data)
        @response = multipart_post(url, data, :headers => headers)

      elsif method == "PUT" && supports_multipart? && has_file?(data)
        @response = multipart_put(url, data, :headers => headers)

      else
        @response = request(url,
          :params => (data && data.any?) ? data : nil,
          :headers => headers,
          :method => method)
      end
    end

    protected

      # multipart_post and multipart_put which use request to do their
      # business through multipart_request. Older implementations of
      # multipart_post and multipart_put use the controller directly.
      def supports_multipart?
        respond_to?(:multipart_request)
      end

      # Recursively search the data for a file attachment.
      def has_file?(data)
        data.each do |key, value|
          if value.is_a?(Hash)
            return has_file?(value)
          else
            return true if value.is_a?(File)
          end
        end
        return false
      end

  end
end

module Merb #:nodoc:
  module Test #:nodoc:
    module RequestHelper #:nodoc:
      def request(uri, env = {})
        @_webrat_session ||= Webrat::MerbSession.new
        @_webrat_session.response = @_webrat_session.request(uri, env)
      end
    end
  end
end

class Merb::Test::RspecStory #:nodoc:
  def browser
    @browser ||= Webrat::MerbSession.new
  end
end
