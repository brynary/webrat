module Webrat #:nodoc:
  module XML #:nodoc:
    
    def self.document(stringlike) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        Webrat.nokogiri_document(stringlike)
      else
        # Webrat::XML.hpricot_document(stringlike)
        Webrat.rexml_document(Webrat::XML.hpricot_document(stringlike).to_html)
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

    def self.to_html(element)
      if Webrat.configuration.parse_with_nokogiri?
        element.to_html
      else
        element.to_s
      end
    end
    
    def self.inner_html(element)
      if Webrat.configuration.parse_with_nokogiri?
        element.inner_html
      else
        element.text
      end
    end
    
    def self.all_inner_text(element)
      if Webrat.configuration.parse_with_nokogiri?
        element.inner_text
      else
        Hpricot(element.to_s).children.first.inner_text
      end
    end
    
    def self.inner_text(element)
      if Webrat.configuration.parse_with_nokogiri?
        element.inner_text
      else
        if defined?(Hpricot::Doc) && element.is_a?(Hpricot::Doc)
          element.inner_text
        else
          element.text
        end
      end
    end
    
    def self.attribute(element, attribute_name)
      return element[attribute_name] if element.is_a?(Hash)
      
      if Webrat.configuration.parse_with_nokogiri?
        element[attribute_name]
      else
        element.attributes[attribute_name]
      end
    end    
    
    def self.xpath_search(element, *searches)
      searches.flatten.map do |search|
        if Webrat.configuration.parse_with_nokogiri?
          element.xpath(search)
        else
          REXML::XPath.match(element, search)
        end
      end.flatten.compact
    end
    
    def self.css_search(element, *searches) #:nodoc:
      # if Webrat.configuration.parse_with_nokogiri?
        xpath_search(element, css_to_xpath(*searches))
        # element.css(*searches)
      # else
      #   searches.map do |search|
      #     element.search(search)
      #   end.flatten.compact
      # end
    end
    
    def self.css_to_xpath(*selectors)
      selectors.map do |rule|
        Nokogiri::CSS.xpath_for(rule, :prefix => ".//")
      end.flatten.uniq
    end
    
  end
end