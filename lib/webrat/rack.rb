require 'webrat'

class CGIMethods #:nodoc:
  def self.parse_query_parameters(params)
    hash = {}
    params.split('&').each do |p|
      pair = p.split('=')
      hash[pair[0]] = pair[1]
    end
    hash
  end
end

module Webrat
  class RackSession < Session #:nodoc:
    def response_body
      @response.body
    end

    def response_code
      @response.status
    end
  end
end
