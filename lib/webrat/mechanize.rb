require "mechanize"

module Webrat #:nodoc:
  class MechanizeSession < Session #:nodoc:
    
    attr_accessor :response
    alias :page :response
    
    def get(url, data, headers_argument_not_used = nil)
      @response = mechanize.get(url, data)
    end

    def post(url, data, headers_argument_not_used = nil)
      post_data = data.inject({}) do |memo, param|
        case param.last
        when Hash
          param.last.each {|attribute, value| memo["#{param.first}[#{attribute}]"] = value }
        else
          memo[param.first] = param.last
        end
        memo
      end
      @response = mechanize.post(url, post_data)
    end
    
    def response_body
      @response.content
    end

    def response_code
      @response.code.to_i
    end
    
    def mechanize
      @mechanize = WWW::Mechanize.new
    end

    def_delegators :mechanize, :basic_auth
      
  end
end

Webrat.configuration.mode = :mechanize