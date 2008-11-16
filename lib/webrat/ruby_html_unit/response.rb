module RubyHtmlUnit
  
  class Response
    def initialize(html_unit_response)
      @html_unit_response = html_unit_response
    end
    
    def success?
      @html_unit_response.status_code / 100 == 2
    end
    
    def content_type
      @html_unit_response.content_type
    end
    
    def body
      @html_unit_response.getContentAsString || ''
    end
    alias_method :text, :body
    
    
  end
  
end