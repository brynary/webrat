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
          rescue Webrat::TimeoutError
            false
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
    end
  end
end
