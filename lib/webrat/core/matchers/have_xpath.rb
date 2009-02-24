require "webrat/core/xml/nokogiri"
require "webrat/core/xml/rexml"

module Webrat
  module Matchers
    
    class HaveXpath #:nodoc:
      def initialize(expected, options = {}, &block)
        @expected = expected
        @options  = options
        @block    = block
      end
    
      def matches?(stringlike, &block)
        @block ||= block
        matched = matches(stringlike)
        
        if @options[:count]
          matched.size == @options[:count] && (!@block || @block.call(matched))
        else
          matched.any? && (!@block || @block.call(matched))
        end
      end
      
      def matches(stringlike)
        if Webrat.configuration.parse_with_nokogiri?
          nokogiri_matches(stringlike)
        else
          rexml_matches(stringlike)
        end
      end
    
      def rexml_matches(stringlike)
        if REXML::Node === stringlike || Array === stringlike
          @query = query.map { |q| q.gsub(%r'//', './') }
        else
          @query = query
        end

        add_options_conditions_to(@query)

        @document = Webrat.rexml_document(stringlike)

        @query.map do |q|
          if @document.is_a?(Array)
            @document.map { |d| REXML::XPath.match(d, q) }
          else
            REXML::XPath.match(@document, q)
          end
        end.flatten.compact
      end
    
      def nokogiri_matches(stringlike)
        if Nokogiri::XML::NodeSet === stringlike
          @query = query.gsub(%r'//', './')
        else
          @query = query
        end
        
        add_options_conditions_to(@query)
        
        @document = Webrat::XML.document(stringlike)
        @document.xpath(*@query)
      end
      
      def add_options_conditions_to(query)
        add_attributes_conditions_to(query)
        add_content_condition_to(query)
      end
      
      def add_attributes_conditions_to(query)
        attribute_conditions = []
        
        @options.each do |key, value|
          next if [:content, :count].include?(key)
          attribute_conditions << "@#{key} = #{xpath_escape(value)}"
        end
        
        if attribute_conditions.any?
          query << "[#{attribute_conditions.join(' and ')}]"
        end
      end
      
      def add_content_condition_to(query)
        if @options[:content]
          query << "[contains(., #{xpath_escape(@options[:content])})]"
        end
      end
      
      def query
        @expected
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
      
    protected
    
      def xpath_escape(string)
        if string.include?("'") && string.include?('"')
          parts = string.split("'").map do |part|
            "'#{part}'"
          end
          
          "concat(" + parts.join(", \"'\", ") + ")"
        elsif string.include?("'")
          "\"#{string}\""
        else
          "'#{string}'"
        end
      end
      
    end
    
    # Matches HTML content against an XPath query
    #
    # ==== Parameters
    # expected<String>:: The XPath query to look for.
    #
    # ==== Returns
    # HaveXpath:: A new have xpath matcher.
    def have_xpath(expected, options = {}, &block)
      HaveXpath.new(expected, options, &block)
    end
    alias_method :match_xpath, :have_xpath
    
    def assert_have_xpath(expected, options = {}, &block)
      hs = HaveXpath.new(expected, options, &block)
      assert hs.matches?(response_body), hs.failure_message
    end
    
    def assert_have_no_xpath(expected, options = {}, &block)
      hs = HaveXpath.new(expected, options, &block)
      assert !hs.matches?(response_body), hs.negative_failure_message
    end
    
  end
end