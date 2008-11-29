module Webrat
  class Area #:nodoc:
    
    def initialize(session, element)
      @session  = session
      @element  = element
    end
    
    def click(method = nil, options = {})
      @session.request_page(absolute_href, :get, {})
    end
    
    def path
      if Webrat.configuration.parse_with_nokogiri?
        @element.path
      else
        @element.xpath
      end
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