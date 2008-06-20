module Webrat
  class MechanizeSession < Session
    
    def initialize(mechanize = WWW::Mechanize.new)
      @mechanize = mechanize
    end
    
    def get(url, data)
      @mechanize_page = @mechanize.get(url, data)
    end

    def post(url, data)
      @mechanize_page = @mechanize.post(url, data)
    end

    def response_body
      @mechanize_page.content
    end

    def response_code
      @mechanize_page.code.to_i
    end
      
  end
end