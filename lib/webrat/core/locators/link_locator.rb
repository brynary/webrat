require "webrat/core/locators/locator"

module Webrat
  module Locators

    class LinkLocator < Locator # :nodoc:

      def locate
        Link.load(@session, link_element)
      end

      def link_element
        matching_links.min { |a, b|
          a_score = a.inner_text =~ matcher ? a.inner_text.length : 100
          b_score = b.inner_text =~ matcher ? b.inner_text.length : 100
          a_score <=> b_score
        }
      end

      def matching_links
        @matching_links ||= link_elements.select do |link_element|
          matches_text?(link_element) ||
          matches_id?(link_element)
        end
      end

      def matches_text?(link)
        replace_nbsp(link.inner_text) =~ matcher ||
        replace_nbsp_ref(link.inner_html) =~ matcher ||
        link["title"] =~ matcher
      end
      
      def matcher
        @matcher ||= begin
          if @value.is_a?(Regexp)
            @value
          else
            /#{Regexp.escape(@value.to_s)}/i
          end
        end
      end

      def matches_id?(link)
        if @value.is_a?(Regexp)
          link["id"] =~ @value ? true : false
        else
          link["id"] == @value ? true : false
        end
      end

      def link_elements
        @dom.xpath(*Link.xpath_search)
      end

      def replace_nbsp(str)
        if str.respond_to?(:valid_encoding?)
          if str.valid_encoding?
            str.gsub(/\xc2\xa0/u, ' ')
          else
            str.force_encoding('UTF-8').gsub(/\xc2\xa0/u, ' ')
          end
        else
          str.gsub(/\xc2\xa0/u, ' ')
        end
      end

      def replace_nbsp_ref(str)
        str.gsub('&#xA0;',' ').gsub('&nbsp;', ' ')
      end

      def error_message
        "Could not find link with text or title or id #{@value.inspect}"
      end

    end

    def find_link(text_or_title_or_id) #:nodoc:
      LinkLocator.new(@session, dom, text_or_title_or_id).locate!
    end

  end
end
