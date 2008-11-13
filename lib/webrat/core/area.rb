module Webrat
  class Area #:nodoc:
    
    def initialize(session, element)
      @session  = session
      @element  = element
    end
    
    def click(method = nil, options = {})
      @session.request_page(absolute_href, :get, {})
    end
    
    def matches_text?(id_or_title)
      matcher = /#{Regexp.escape(id_or_title.to_s)}/i
      title =~ matcher || id =~ matcher
    end
    
    protected
    
    def href
      @element["href"]
    end
    
    def title
      @element["title"]
    end
    
    def id
      @element["id"]
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