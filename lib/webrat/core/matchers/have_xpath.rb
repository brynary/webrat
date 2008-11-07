module Webrat
  module Matchers
    
    class HaveXpath
      def initialize(expected, &block)
        @expected = expected
        @block    = block
      end
    
      def matches?(stringlike)
        if defined?(Nokogiri::XML)
          matches_nokogiri?(stringlike)
        else
          matches_rexml?(stringlike)
        end
      end
    
      def matches_rexml?(stringlike)
        @document = rexml_document(stringlike)
      
        query.all? do |q|
          matched = REXML::XPath.match(@document, q)
          matched.any? && (!block_given? || matched.all?(&@block))
        end
      end
    
      def matches_nokogiri?(stringlike)
        @document = Webrat.nokogiri_document(stringlike)
        @document.xpath(*query).any?
      end
    
      def rexml_document(stringlike)
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
        
        case stringlike
        when REXML::Document
          stringlike.root
        when REXML::Node
          stringlike
        when StringIO, String
          begin
            REXML::Document.new(stringlike.to_s).root
          rescue REXML::ParseException => e
            if e.message.include?("second root element")
              REXML::Document.new("<fake-root-element>#{stringlike}</fake-root-element>").root
            else
              raise e
            end
          end
        end
      end
      
      def query
        [@expected].flatten.compact
      end
    
      # ==== Returns
      # String:: The failure message.
      def failure_message
        "expected following text to match xpath #{@expected}:\n#{@document}"
      end

      # ==== Returns
      # String:: The failure message to be displayed in negative matches.
      def negative_failure_message
        "expected following text to not match xpath #{@expected}:\n#{@document}"
      end    
    end
    
    # Matches HTML content against an XPath query
    #
    # ==== Parameters
    # expected<String>:: The XPath query to look for.
    #
    # ==== Returns
    # HaveXpath:: A new have xpath matcher.
    # ---
    # @api public
    def have_xpath(expected)
      HaveXpath.new(expected)
    end
    alias_method :match_xpath, :have_xpath
    
  end
end