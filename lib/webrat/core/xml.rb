module Webrat
  module XML
    
    def self.document(stringlike)
      if defined?(Nokogiri::XML)
        Webrat.nokogiri_document(stringlike)
      else
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
    end
    
    def self.css_search(element, *searches)
      if defined?(Nokogiri::XML)
        element.css(*searches)
      else
        searches.map do |search|
          element.search(search)
        end.flatten.compact
      end
    end
    
  end
end