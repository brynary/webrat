module Webrat
  module Matchers
    
    class HaveXpath #:nodoc:
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
        @query = query

        @document = rexml_document(stringlike)

        matched = @query.map do |q|
          if @document.is_a?(Array)
            @document.map { |d| REXML::XPath.match(d, q) }
          else
            REXML::XPath.match(@document, q)
          end
        end.flatten.compact

        matched.any? && (!@block || @block.call(matched))
      end
    
      def matches_nokogiri?(stringlike)
        if Nokogiri::XML::NodeSet === stringlike
          @query = query.map { |q| q.gsub(%r'//', './') }
        else
          @query = query
        end
        
        @document = Webrat.nokogiri_document(stringlike)
        matched = @document.xpath(*@query)
        matched.any? && (!@block || @block.call(matched))
      end
    
      def rexml_document(stringlike)
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
        
        case stringlike
        when REXML::Document
          stringlike.root
        when REXML::Node, Array
          @query = query.map { |q| q.gsub(%r'//', './') }
          stringlike
        else
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
    def have_xpath(expected, &block)
      HaveXpath.new(expected, &block)
    end
    alias_method :match_xpath, :have_xpath
    
  end
end