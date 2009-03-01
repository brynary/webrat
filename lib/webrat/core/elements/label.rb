require "webrat/core/elements/element"

module Webrat
  class Label < Element #:nodoc:
    
    attr_reader :element
    
    def self.xpath_search
      ".//label"
    end

    def for_id
      Webrat::XML.attribute(@element, "for")
    end
    
    def field
      Field.load(@session, field_element)
    end
    
  protected
  
    def field_element
      if for_id.blank?
        Webrat::XML.xpath_at(@element, *Field.xpath_search_excluding_hidden)
      else
        Webrat::XML.css_search(@session.current_dom, "#" + for_id).first
      end
    end
    
  end
end
