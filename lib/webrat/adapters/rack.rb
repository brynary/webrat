require "rack/test"

module Webrat
  class RackAdapter
    extend Forwardable

    attr :session
    def_delegators :@session, :get, :post, :put, :delete

    def initialize(session) #:nodoc:
      @session = session
    end

    def response_body
      response.body
    end

    def response_code
      response.status
    end

    def response_headers
      response.headers
    end

    def response
      @session.last_response
    end
  end
end
