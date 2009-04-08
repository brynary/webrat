require "webrat/core/elements/element"

module Webrat
  class Area < Element #:nodoc:

    def self.xpath_search
      ".//area"
    end

    def click(method = nil, options = {})
      @session.request_page(absolute_href, :get, {})
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
