module Webrat #:nodoc:
  module XML #:nodoc:
    
    def self.document(stringlike) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        Webrat.nokogiri_document(stringlike)
      else
        Webrat::XML.hpricot_document(stringlike)
      end
    end
    
    def self.hpricot_document(stringlike)
      return stringlike.dom if stringlike.respond_to?(:dom)

      if Hpricot::Doc === stringlike
        stringlike
      elsif Hpricot::Elements === stringlike
        stringlike
      elsif StringIO === stringlike
        Hpricot(stringlike.string)
      elsif stringlike.respond_to?(:body)
        Hpricot(stringlike.body.to_s)
      else
        Hpricot(stringlike.to_s)
      end
    end

    def self.attribute(element, attribute_name)
      element[attribute_name]
    end    
    
    def self.xpath_search(element, *searches)
      searches.flatten.map do |search|
        element.xpath(search)
      end.flatten.compact
    end
    
    def self.css_search(element, *searches) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        xpath_search(element, css_to_xpath(*searches))
        # element.css(*searches)
      else
        searches.map do |search|
          element.search(search)
        end.flatten.compact
      end
    end
    
    def self.css_to_xpath(*selectors)
      selectors.map do |rule|
        Nokogiri::CSS.xpath_for(rule, :prefix => ".//")
      end.flatten.uniq
    end
    
  end
end