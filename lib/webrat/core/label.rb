module Webrat
  class Label #:nodoc:
    
    def initialize(field, element)
      @field    = field
      @element  = element
    end
    
    def matches_text?(label_text)
      text =~ /^\W*#{Regexp.escape(label_text.to_s)}\b/i
    end
    
    def text
      str = @element.inner_text
      str.gsub!("\n","")
      str.strip!
      str.squeeze!(" ")
      str
    end

    def for_id
      @element['for']
    end
    
  end
end
