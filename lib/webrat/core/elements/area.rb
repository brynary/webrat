require "webrat/core/elements/element"

module Webrat
  class Area < Element #:nodoc:

    def self.xpath_search
      ".//area"
    end

    def click(method = nil, options = {})
      @session.request_page(href, :get, {})
    end

  protected

    def href
      Webrat::XML.attribute(@element, "href")
    end
  end
end
