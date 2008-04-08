module Webrat
  class SelectOption
    
    def initialize(select, element)
      @select = select
      @element = element
    end
    
    def matches_text?(text)      
      @element.innerHTML == text.to_s
    end
    
    def choose
      @select.set(value)
    end
    
  protected
  
    def value
      @element["value"] || @element.innerHTML
    end
    
  end
end