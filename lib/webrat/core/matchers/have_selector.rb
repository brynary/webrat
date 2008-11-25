module Webrat
  module Matchers
    
    class HaveSelector < HaveXpath #:nodoc:

      # ==== Returns
      # String:: The failure message.
      def failure_message
        "expected following text to match selector #{@expected}:\n#{@document}"
      end
    
      # ==== Returns
      # String:: The failure message to be displayed in negative matches.
      def negative_failure_message
        "expected following text to not match selector #{@expected}:\n#{@document}"
      end
    
      def query
        Nokogiri::CSS::Parser.parse(*super).map { |ast| ast.to_xpath }
      end
  
    end
    
    # Matches HTML content against a CSS 3 selector.
    #
    # ==== Parameters
    # expected<String>:: The CSS selector to look for.
    #
    # ==== Returns
    # HaveSelector:: A new have selector matcher.
    def have_selector(expected, &block)
      HaveSelector.new(expected, &block)
    end
    alias_method :match_selector, :have_selector
    
  end
end