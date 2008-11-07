module Webrat
  class SelectOption #:nodoc:
    
    def initialize(select, element)
      @select = select
      @element = element
    end
    
    def matches_text?(text)
      if text.is_a?(Regexp)
        @element.inner_html =~ text
      else
        @element.inner_html == text.to_s
      end
    end
    
    def choose
      @select.raise_error_if_disabled
      @select.set(value)
    end
    
  protected
  
    def value
      @element["value"] || @element.inner_html
    end
    
  end
end