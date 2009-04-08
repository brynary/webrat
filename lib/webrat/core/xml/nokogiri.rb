require "webrat/core_extensions/meta_class"

module Webrat

  def self.nokogiri_document(stringlike) #:nodoc:
    return stringlike.dom if stringlike.respond_to?(:dom)

    if Nokogiri::HTML::Document === stringlike
      stringlike
    elsif Nokogiri::XML::NodeSet === stringlike
      stringlike
    elsif StringIO === stringlike
      Nokogiri::HTML(stringlike.string)
    elsif stringlike.respond_to?(:body)
      Nokogiri::HTML(stringlike.body.to_s)
    else
      Nokogiri::HTML(stringlike.to_s)
    end
  end

  def self.html_nokogiri_document(stringlike) #:nodoc:
    return stringlike.dom if stringlike.respond_to?(:dom)

    if Nokogiri::HTML::Document === stringlike
      stringlike
    elsif Nokogiri::XML::NodeSet === stringlike
      stringlike
    elsif StringIO === stringlike
      Nokogiri::HTML(stringlike.string)
    elsif stringlike.respond_to?(:body)
      Nokogiri::HTML(stringlike.body.to_s)
    else
      Nokogiri::HTML(stringlike.to_s)
    end
  end

  def self.xml_nokogiri_document(stringlike) #:nodoc:
    return stringlike.dom if stringlike.respond_to?(:dom)

    if Nokogiri::HTML::Document === stringlike
      stringlike
    elsif Nokogiri::XML::NodeSet === stringlike
      stringlike
    elsif StringIO === stringlike
      Nokogiri::XML(stringlike.string)
    elsif stringlike.respond_to?(:body)
      Nokogiri::XML(stringlike.body.to_s)
    else
      Nokogiri::XML(stringlike.to_s)
    end
  end

  def self.define_dom_method(object, dom) #:nodoc:
    object.meta_class.send(:define_method, :dom) do
      dom
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
