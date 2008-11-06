module Webrat
  module Matchers
  
    class HaveXpath
      def initialize(expected, &block)
        # Require nokogiri and fall back on rexml
        begin
          require "nokogiri"
        rescue LoadError => e
          if require "rexml/document"
            require "merb-core/vendor/nokogiri/css"
            warn("Standard REXML library is slow. Please consider installing nokogiri.\nUse \"sudo gem install nokogiri\"")
          end
        end
      
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
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
      
        @document = case stringlike
        when REXML::Document
          stringlike.root
        when REXML::Node
          stringlike
        when StringIO, String
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
      
        query.all? do |q|
          matched = REXML::XPath.match(@document, q)
          matched.any? && (!block_given? || matched.all?(&@block))
        end
      end
    
      def matches_nokogiri?(stringlike)
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
      
        @document = case stringlike
        when Nokogiri::HTML::Document, Nokogiri::XML::NodeSet
          stringlike
        when StringIO
          Nokogiri::HTML(stringlike.string)
        else
          Nokogiri::HTML(stringlike.to_s)
        end
        @document.xpath(*query).any?
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
  
    class HaveSelector < HaveXpath

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
  
    class HaveTag < HaveSelector
    
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
      
        Nokogiri::CSS::Parser.parse(selector).map { |ast| ast.to_xpath }
      end
    
    end

    class HasContent
      def initialize(content)
        @content = content
      end

      def matches?(element)
        element = element.body.to_s if element.respond_to?(:body)
        @element = element
      
        case @content
        when String
          @element.contains?(@content)
        when Regexp
          @element.matches?(@content)
        end
      end
    
      # ==== Returns
      # String:: The failure message.
      def failure_message
        "expected the following element's content to #{content_message}:\n#{@element.inner_text}"
      end

      # ==== Returns
      # String:: The failure message to be displayed in negative matches.
      def negative_failure_message
        "expected the following element's content to not #{content_message}:\n#{@element.inner_text}"
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

    # Matches HTML content against a CSS 3 selector.
    #
    # ==== Parameters
    # expected<String>:: The CSS selector to look for.
    #
    # ==== Returns
    # HaveSelector:: A new have selector matcher.
    # ---
    # @api public
    def have_selector(expected)
      HaveSelector.new(expected)
    end
    alias_method :match_selector, :have_selector

    # Matches HTML content against an XPath query
    #
    # ==== Parameters
    # expected<String>:: The XPath query to look for.
    #
    # ==== Returns
    # HaveXpath:: A new have xpath matcher.
    # ---
    # @api public
    def have_xpath(expected)
      HaveXpath.new(expected)
    end
    alias_method :match_xpath, :have_xpath
  
    def have_tag(name, attributes = {})
      HaveTag.new([name, attributes])
    end
    alias_method :match_tag, :have_tag
  
    # Matches the contents of an HTML document with
    # whatever string is supplied
    #
    # ---
    # @api public
    def contain(content)
      HasContent.new(content)
    end
  
  end
end
