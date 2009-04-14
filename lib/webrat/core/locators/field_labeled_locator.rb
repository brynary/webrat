require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators

    class FieldLabeledLocator < Locator # :nodoc:

      def locate
        matching_labels.any? && matching_labels.detect_mapped { |label| label.field }
      end

      def matching_labels
        matching_label_elements.sort_by do |label_element|
          text(label_element).length
        end.map do |label_element|
          Label.load(@session, label_element)
        end
      end

      def matching_label_elements
        label_elements.select do |label_element|
          text(label_element) =~ /^\W*#{Regexp.escape(@value.to_s)}(\b|\Z)/i
        end
      end

      def label_elements
        Webrat::XML.xpath_search(@dom, Label.xpath_search)
      end

      def error_message
        "Could not find field labeled #{@value.inspect}"
      end

      def text(element)
        str = Webrat::XML.all_inner_text(element)
        str.gsub!("\n","")
        str.strip!
        str.squeeze!(" ")
        str
      end

    end

    # Locates a form field based on a <tt>label</tt> element in the HTML source.
    # This can be useful in order to verify that a field is pre-filled with the
    # correct value.
    #
    # Example:
    #   field_labeled("First name").value.should == "Bryan"
    def field_labeled(label, *field_types)
      FieldLabeledLocator.new(@session, dom, label, *field_types).locate!
    end

  end
end
