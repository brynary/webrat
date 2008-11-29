module Webrat
  class Area #:nodoc:
    
    def self.css_search
      "area"
    end
    
    def initialize(session, element)
      @session  = session
      @element  = element
    end
    
    def click(method = nil, options = {})
      @session.request_page(absolute_href, :get, {})
    end
    
    def path
      Webrat::XML.xpath_to(@element)
    end
    
  protected
    
    def href
      Webrat::XML.attribute(@element, "href")
    end
   
    def absolute_href
      if href =~ /^\?/
        "#{@session.current_url}#{href}"
      elsif href !~ %r{^https?://[\w|.]+(/.*)} && (href !~ /^\//)
        "#{@session.current_url}/#{href}"
      else
        href
      end
    end
    
  end
end