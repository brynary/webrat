module Webrat
  module Matchers
  
    class HasContent #:nodoc:
      def initialize(content)
        @content = content
      end
      
      def matches?(stringlike)
        if Webrat.configuration.parse_with_nokogiri?
          @document = Webrat.nokogiri_document(stringlike)
        else
          @document = Webrat.hpricot_document(stringlike)
        end
        
        @element = Webrat::XML.inner_text(@document)
      
        case @content
        when String
          @element.include?(@content)
        when Regexp
          @element.match(@content)
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
    
  end
end