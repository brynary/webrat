require "webrat/core/xml/nokogiri"
require "webrat/core/xml/hpricot"
require "webrat/core/xml/rexml"

module Webrat #:nodoc:
  module XML #:nodoc:

    def self.document(stringlike) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        Webrat.nokogiri_document(stringlike)
      else
        Webrat.rexml_document(Webrat.hpricot_document(stringlike).to_html)
      end
    end

    def self.html_document(stringlike) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        Webrat.html_nokogiri_document(stringlike)
      else
        Webrat.rexml_document(Webrat.hpricot_document(stringlike).to_html)
      end
    end

    def self.xml_document(stringlike) #:nodoc:
      if Webrat.configuration.parse_with_nokogiri?
        Webrat.xml_nokogiri_document(stringlike)
      else
        Webrat.rexml_document(Webrat.hpricot_document(stringlike).to_html)
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

    def self.xpath_to(element)
      if Webrat.configuration.parse_with_nokogiri?
        element.path
      else
        element.xpath
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

    def self.xpath_at(*args)
      xpath_search(*args).first
    end

    def self.css_at(*args)
      css_search(*args).first
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
      xpath_search(element, css_to_xpath(*searches))
    end

    def self.css_to_xpath(*selectors)
      selectors.map do |rule|
        Nokogiri::CSS.xpath_for(rule, :prefix => ".//")
      end.flatten.uniq
    end

  end
end
