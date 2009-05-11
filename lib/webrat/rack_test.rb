module Webrat
  class RackTestSession < Session

    def initialize(rack_test_session) #:nodoc:
      super()
      @rack_test_session = rack_test_session
    end

    def response_body
      response.body
    end

    def response_code
      response.status
    end

    def response
      @rack_test_session.last_response
    end

  protected

    def process_request(http_method, url, data = {}, headers = {})
      headers ||= {}
      data    ||= {}

      env = headers.merge(:params => data, :method => http_method.to_s.upcase)
      @rack_test_session.request(url, env)
    end

  end
end
