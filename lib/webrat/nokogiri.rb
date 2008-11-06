module Nokogiri
  module CSS
    class XPathVisitor
      
      def visit_pseudo_class_text(node)
        "@type='text'"
      end

      def visit_pseudo_class_password(node)
        "@type='password'"
      end
      
    end
  end
end