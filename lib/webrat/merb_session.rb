require "webrat"
require "merb-core"
require "webrat/merb_multipart_support"

module Webrat
  class MerbSession < Session #:nodoc:
    include Merb::Test::MakeRequest

    # Include Webrat's own version of multipart_post/put because the officially
    # supported methods in Merb don't perform the request correctly.
    include MerbMultipartSupport

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
      if method == "POST" && has_file?(data)
        @response = multipart_post(url, data, :headers => headers)

      elsif method == "PUT" && has_file?(data)
        @response = multipart_put(url, data, :headers => headers)

      else
        @response = request(url,
          :params => (data && data.any?) ? data : nil,
          :headers => headers,
          :method => method)
      end
    end

    protected

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
