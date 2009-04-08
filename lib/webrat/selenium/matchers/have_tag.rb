module Webrat
  module Selenium
    module Matchers

      class HaveTag < HaveSelector #:nodoc:
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

          selector << ":contains('#{options.delete(:content)}')" if options[:content]

          options.each do |key, value|
            selector << "[#{key}='#{value}']"
          end

          Nokogiri::CSS.parse(selector).map { |ast| ast.to_xpath }
        end
      end

      def have_tag(name, attributes = {}, &block)
        HaveTag.new([name, attributes], &block)
      end

      alias_method :match_tag, :have_tag

      # Asserts that the body of the response contains
      # the supplied tag with the associated selectors
      def assert_have_tag(name, attributes = {})
        ht = HaveTag.new([name, attributes])
        assert ht.matches?(response), ht.failure_message
      end

      # Asserts that the body of the response
      # does not contain the supplied string or regepx
      def assert_have_no_tag(name, attributes = {})
        ht = HaveTag.new([name, attributes])
        assert !ht.matches?(response), ht.negative_failure_message
      end

    end
  end
end
