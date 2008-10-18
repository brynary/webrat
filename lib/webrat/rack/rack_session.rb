require 'webrat'

module Webrat
  class RackSession < Session
    def response_body
      @response.body
    end

    def response_code
      @response.status
    end
  end
end