module Webrat
  
  def self.nokogiri_document(stringlike)
    return stringlike.dom if stringlike.respond_to?(:dom)
    
    if stringlike === Nokogiri::HTML::Document || stringlike === Nokogiri::XML::NodeSet
      stringlike
    elsif stringlike === StringIO
      Nokogiri::HTML(stringlike.string)
    elsif stringlike.respond_to?(:body)
      Nokogiri::HTML(stringlike.body.to_s)
    else
      Nokogiri::HTML(stringlike.to_s)
    end
  end
  
end


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