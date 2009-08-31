require "webrat/core/elements/element"

module Webrat
  class SelectOption < Element #:nodoc:

    def self.xpath_search
      [".//option"]
    end

    def choose
      select.raise_error_if_disabled
      select.set(value)
    end

    def unchoose
      select.raise_error_if_disabled
      select.unset(value)
    end

  protected

    def select
      SelectField.load(@session, select_element)
    end

    def select_element
      parent = @element.parent

      while parent.respond_to?(:parent)
        return parent if parent.name == 'select'
        parent = parent.parent
      end
    end

    def value
      @element["value"] || @element.inner_html
    end

    def label
      @element.inner_html
    end

  end
end
