require "webrat/core/locators/locator"

module Webrat
  module Locators
    
    class LinkLocator < Locator
  
      def locate
        @scope.link_by_element(link_element)
      end
  
      def link_element
        matching_links.min { |a, b| Webrat::XML.all_inner_text(a).length <=> Webrat::XML.all_inner_text(b).length }
      end
  
      def matching_links
        @matching_links ||= link_elements.select do |link_element|
          matches_text?(link_element) ||
          matches_id?(link_element)
        end
      end
  
      def matches_text?(link)
        if @value.is_a?(Regexp)
          matcher = @value
        else
          matcher = /#{Regexp.escape(@value.to_s)}/i
        end

        replace_nbsp(Webrat::XML.all_inner_text(link)) =~ matcher ||
        replace_nbsp_ref(Webrat::XML.inner_html(link)) =~ matcher ||
        Webrat::XML.attribute(link, "title")=~ matcher
      end

      def matches_id?(link)
        if @value.is_a?(Regexp)
          (Webrat::XML.attribute(link, "id") =~ @value) ? true : false
        else
          (Webrat::XML.attribute(link, "id") == @value) ? true : false
        end
      end
  
      def link_elements
        Webrat::XML.css_search(@scope.dom, *Link.css_search)
      end
  
      def replace_nbsp(str)
        str.gsub([0xA0].pack('U'), ' ')
      end

      def replace_nbsp_ref(str)
        str.gsub('&#xA0;',' ').gsub('&nbsp;', ' ')
      end
  
    end
    
  end
end