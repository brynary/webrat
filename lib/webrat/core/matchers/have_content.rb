module Webrat
  module Matchers
  
    class HasContent
      def initialize(content)
        # Require nokogiri and fall back on rexml
        begin
          require "nokogiri"
          require "webrat/nokogiri"
        rescue LoadError => e
          if require "rexml/document"
            require "webrat/vendor/nokogiri/css"
            warn("Standard REXML library is slow. Please consider installing nokogiri.\nUse \"sudo gem install nokogiri\"")
          end
        end
        
        @content = content
      end
      
      def matches?(stringlike)
        if defined?(Nokogiri::XML)
          matches_nokogiri?(stringlike)
        else
          matches_rexml?(stringlike)
        end
      end
    
      def matches_rexml?(stringlike)
        @document = rexml_document(stringlike)
        @element = @document.inner_text
      
        case @content
        when String
          @element.include?(@content)
        when Regexp
          @element.match(@content)
        end
      end
    
      def matches_nokogiri?(stringlike)
        @document = nokogiri_document(stringlike)
        @element = @document.inner_text
      
        case @content
        when String
          @element.include?(@content)
        when Regexp
          @element.match(@content)
        end
      end
    
      def rexml_document(stringlike)
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
        
        case stringlike
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
      end
      
      def nokogiri_document(stringlike)
        return stringlike.dom if stringlike.respond_to?(:dom)
        stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)
        
        case stringlike
        when Nokogiri::HTML::Document, Nokogiri::XML::NodeSet
          stringlike
        when StringIO
          Nokogiri::HTML(stringlike.string)
        else
          Nokogiri::HTML(stringlike.to_s)
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
    #
    # ---
    # @api public
    def contain(content)
      HasContent.new(content)
    end
    
  end
end