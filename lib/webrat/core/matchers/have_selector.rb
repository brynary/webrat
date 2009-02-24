require "webrat/core/matchers/have_xpath"

module Webrat
  module Matchers
    
    class HaveSelector < HaveXpath #:nodoc:
      # ==== Returns
      # String:: The failure message.
      def failure_message
        "expected following output to contain a #{tag_inspect} tag:\n#{@document}"
      end

      # ==== Returns
      # String:: The failure message to be displayed in negative matches.
      def negative_failure_message
        "expected following output to omit a #{tag_inspect}:\n#{@document}"
      end

      def matches?(stringlike, &block)
        @block ||= block
        matched = matches(stringlike)
        
        options = @expected.last.dup
        
        if options[:count]
          matched.size == options[:count] && (!@block || @block.call(matched))
        else
          matched.any? && (!@block || @block.call(matched))
        end
      end
      
      def tag_inspect
        options = @expected.last.dup
        content = options.delete(:content)

        html = "<#{@expected.first}"
        options.each do |k,v|
          html << " #{k}='#{v}'"
        end

        if content
          html << ">#{content}</#{@expected.first}>"
        else
          html << "/>"
        end

        html
      end

      def query
        options  = @expected.last.dup
        selector = @expected.first.to_s
        
        options.each do |key, value|
          next if [:content, :count].include?(key)
          selector << "[#{key}='#{value}']"
        end
        
        q = Nokogiri::CSS::Parser.parse(selector).map { |ast| ast.to_xpath }.first
        
        if options[:content] && options[:content].include?("'") && options[:content].include?('"')
          parts = options[:content].split("'").map do |part|
            "'#{part}'"
          end
          
          string = "concat(" + parts.join(", \"'\", ") + ")"
          q << "[contains(., #{string})]"
        elsif options[:content] && options[:content].include?("'")
          q << "[contains(., \"#{options[:content]}\")]"
        elsif options[:content]
          q << "[contains(., '#{options[:content]}')]"
        end
        
        q
      end
      
    end
    
    # Matches HTML content against a CSS 3 selector.
    #
    # ==== Parameters
    # expected<String>:: The CSS selector to look for.
    #
    # ==== Returns
    # HaveSelector:: A new have selector matcher.
    def have_selector(name, attributes = {}, &block)
      HaveSelector.new([name, attributes], &block)
    end
    alias_method :match_selector, :have_selector
    
    
    # Asserts that the body of the response contains
    # the supplied selector
    def assert_have_selector(name, attributes = {}, &block)
      matcher = HaveSelector.new([name, attributes], &block)
      assert matcher.matches?(response_body), matcher.failure_message
    end
    
    # Asserts that the body of the response
    # does not contain the supplied string or regepx
    def assert_have_no_selector(name, attributes = {}, &block)
      matcher = HaveSelector.new([name, attributes], &block)
      assert !matcher.matches?(response_body), matcher.negative_failure_message
    end
    
  end
end