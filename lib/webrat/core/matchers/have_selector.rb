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
      
      def tag_inspect
        options = @options.dup
        count = options.delete(:count)
        content = options.delete(:content)

        html = "<#{@expected}"
        options.each do |k,v|
          html << " #{k}='#{v}'"
        end

        if content
          html << ">#{content}</#{@expected}>"
        else
          html << "/>"
        end

        html
      end

      def query
        Nokogiri::CSS.parse(@expected.to_s).map do |ast|
          ast.to_xpath
        end.first
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
      HaveSelector.new(name, attributes, &block)
    end
    alias_method :match_selector, :have_selector
    
    
    # Asserts that the body of the response contains
    # the supplied selector
    def assert_have_selector(name, attributes = {}, &block)
      matcher = HaveSelector.new(name, attributes, &block)
      assert matcher.matches?(response_body), matcher.failure_message
    end
    
    # Asserts that the body of the response
    # does not contain the supplied string or regepx
    def assert_have_no_selector(name, attributes = {}, &block)
      matcher = HaveSelector.new(name, attributes, &block)
      assert !matcher.matches?(response_body), matcher.negative_failure_message
    end
    
  end
end