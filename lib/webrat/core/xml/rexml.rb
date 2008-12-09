module Webrat
  
  def self.rexml_document(stringlike)
    stringlike = stringlike.body.to_s if stringlike.respond_to?(:body)

    case stringlike
    when REXML::Document
      stringlike.root
    when REXML::Node, Array
      stringlike
    else
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
  
end