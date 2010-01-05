module Webrat
  module Selenium
    module Matchers
      class HaveSelector
        def initialize(expected)
          @expected = expected
        end

        def matches?(response)
          response.session.wait_for do
            response.selenium.is_element_present("css=#{@expected}")
          end
          rescue Webrat::TimeoutError
            false
        end

        def does_not_match?(response)
          response.session.wait_for do
            !response.selenium.is_element_present("css=#{@expected}")
          end
          rescue Webrat::TimeoutError
            false
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
    end
  end
end
