require "webrat/core_extensions/detect_mapped"
require "webrat/core/locators/locator"

module Webrat
  module Locators

    class SelectOptionLocator < Locator # :nodoc:

      def initialize(session, dom, option_text, id_or_name_or_label)
        @session = session
        @dom = dom
        @option_text = option_text
        @id_or_name_or_label = id_or_name_or_label
      end

      def locate
        if @id_or_name_or_label
          field = FieldLocator.new(@session, @dom, @id_or_name_or_label, SelectField).locate!

          field.options.detect do |o|
            if @option_text.is_a?(Regexp)
              o.element.inner_html =~ @option_text
            else
              o.inner_text == @option_text.to_s
            end
          end
        else
          option_element = option_elements.detect do |o|
            if @option_text.is_a?(Regexp)
              o.inner_html =~ @option_text
            else
              o.inner_text == @option_text.to_s
            end
          end

          SelectOption.load(@session, option_element)
        end
      end

      def option_elements
        @dom.xpath(*SelectOption.xpath_search)
      end

      def error_message
        if @id_or_name_or_label
          "The '#{@option_text}' option was not found in the #{@id_or_name_or_label.inspect} select box"
        else
          "Could not find option #{@option_text.inspect}"
        end
      end

    end

    def select_option(option_text, id_or_name_or_label = nil) #:nodoc:
      SelectOptionLocator.new(@session, dom, option_text, id_or_name_or_label).locate!
    end

  end
end
