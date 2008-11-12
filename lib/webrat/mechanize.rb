require "mechanize"

module Webrat
  class MechanizeSession < Session
    
    def initialize(mechanize = WWW::Mechanize.new)
      super()
      @mechanize = mechanize
    end
    
    def page
      @mechanize_page
    end
    
    def get(url, data, headers_argument_not_used = nil)
      @mechanize_page = @mechanize.get(url, data)
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
      @mechanize_page = @mechanize.post(url, post_data)
    end

    def response_body
      @mechanize_page.content
    end

    def response_code
      @mechanize_page.code.to_i
    end
      
  end
end