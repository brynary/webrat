module Webrat
  class Label #:nodoc:
    
    attr_reader :element
    
    def self.xpath_search
      ".//label"
    end
    
    def initialize(field, element)
      @field    = field
      @element  = element
    end
    
    def text
      str = Webrat::XML.all_inner_text(@element)
      str.gsub!("\n","")
      str.strip!
      str.squeeze!(" ")
      str
    end

    def for_id
      Webrat::XML.attribute(@element, "for")
    end
    
  end
end
