require "webrat/core/elements/element"

module Webrat
  class Label < Element #:nodoc:

    attr_reader :element

    def self.xpath_search
      [".//label"]
    end

    def for_id
      @element["for"]
    end

    def field
      Field.load(@session, field_element)
    end

  protected

    def field_element
      if for_id.blank?
        @element.xpath(*Field.xpath_search_excluding_hidden).first
      else
        @session.current_dom.css("#" + for_id).first
      end
    end

  end
end
