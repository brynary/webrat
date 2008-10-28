module Webrat
  class SelectOption
    
    def initialize(select, element)
      @select = select
      @element = element
    end
    
    def matches_text?(text)
      if text.is_a?(Regexp)
        @element.innerHTML =~ text
      else
        @element.innerHTML == text.to_s
      end
    end
    
    def choose
      @select.raise_error_if_disabled
      @select.set(value)
    end
    
  protected
  
    def value
      @element["value"] || @element.innerHTML
    end
    
  end
end