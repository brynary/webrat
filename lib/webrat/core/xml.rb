require "webrat/core_extensions/meta_class"

module Webrat #:nodoc:
  module XML #:nodoc:

    def self.document(stringlike) #:nodoc:
      return stringlike.dom if stringlike.respond_to?(:dom)

      case stringlike
      when Nokogiri::HTML::Document, Nokogiri::XML::NodeSet
        stringlike
      else
        stringlike = stringlike.body if stringlike.respond_to?(:body)
        stringlike = stringlike.to_s

        if stringlike =~ /\<\?xml/
          Nokogiri::XML(stringlike)
        else
          Nokogiri::HTML(stringlike)
        end
      end
    end

    def self.define_dom_method(object, dom) #:nodoc:
      object.meta_class.send(:define_method, :dom) do
        dom
      end
    end

  end
end

module Nokogiri #:nodoc:
  module CSS #:nodoc:
    class XPathVisitor #:nodoc:

      def visit_pseudo_class_text(node) #:nodoc:
        "@type='text'"
      end

      def visit_pseudo_class_password(node) #:nodoc:
        "@type='password'"
      end

    end
  end
end

