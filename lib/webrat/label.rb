module Webrat
  class Label
    
    def initialize(field, element)
      @field    = field
      @element  = element
    end
    
    def matches_text?(label_text)
      text =~ /^\W*#{Regexp.escape(label_text.to_s)}\b/i
    end
    
    def text
      @element.innerText
    end
    
  end
end