module Webrat
  module Selenium
    module Matchers

      class HaveXpath
        def initialize(expected)
          @expected = expected
        end
        
        def matches?(response)
          response.session.wait_for do
            response.selenium.is_element_present("xpath=#{@expected}")
          end
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
      
      def have_xpath(xpath)
        HaveXpath.new(xpath)
      end
      
      def assert_have_xpath(expected)
        hs = HaveXpath.new(expected)
        assert hs.matches?(response), hs.failure_message
      end

      def assert_have_no_xpath(expected)
        hs = HaveXpath.new(expected)
        assert !hs.matches?(response), hs.negative_failure_message
      end
      
      class HaveSelector
        def initialize(expected)
          @expected = expected
        end
        
        def matches?(response)
          response.session.wait_for do
            response.selenium.is_element_present("css=#{@expected}")
          end
        end

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
      end
      
      def have_selector(content)
        HaveSelector.new(content)
      end
      
      # Asserts that the body of the response contains
      # the supplied selector
      def assert_have_selector(expected)
        hs = HaveSelector.new(expected)
        assert hs.matches?(response), hs.failure_message
      end

      # Asserts that the body of the response
      # does not contain the supplied string or regepx
      def assert_have_no_selector(expected)
        hs = HaveSelector.new(expected)
        assert !hs.matches?(response), hs.negative_failure_message
      end
      
      class HasContent #:nodoc:
        def initialize(content)
          @content = content
        end
        
        def matches?(response)
          if @content.is_a?(Regexp)
            text_finder = "regexp:#{@content.source}"
          else
            text_finder = @content
          end
          
          response.session.wait_for do
            response.selenium.is_text_present(text_finder)
          end
        end

        # ==== Returns
        # String:: The failure message.
        def failure_message
          "expected the following element's content to #{content_message}:\n#{@element}"
        end

        # ==== Returns
        # String:: The failure message to be displayed in negative matches.
        def negative_failure_message
          "expected the following element's content to not #{content_message}:\n#{@element}"
        end

        def content_message
          case @content
          when String
            "include \"#{@content}\""
          when Regexp
            "match #{@content.inspect}"
          end
        end
      end

      # Matches the contents of an HTML document with
      # whatever string is supplied
      def contain(content)
        HasContent.new(content)
      end
      
      # Asserts that the body of the response contain
      # the supplied string or regexp
      def assert_contain(content)
        hc = HasContent.new(content)
       assert hc.matches?(response), hc.failure_message
      end

      # Asserts that the body of the response
      # does not contain the supplied string or regepx
      def assert_not_contain(content)
        hc = HasContent.new(content)
        assert !hc.matches?(response), hc.negative_failure_message
      end
      
    end
  end
end