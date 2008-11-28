module Webrat
  class SelectOption #:nodoc:
    
    def initialize(select, element)
      @select = select
      @element = element
    end
    
    def matches_text?(text)
      if text.is_a?(Regexp)
        Webrat::XML.inner_html(@element) =~ text
      else
        Webrat::XML.inner_html(@element) == text.to_s
      end
    end
    
    def choose
      @select.raise_error_if_disabled
      @select.set(value)
    end
    
  protected
  
    def value
      Webrat::XML.attribute(@element, "value") || Webrat::XML.inner_html(@element)
    end
    
  end
end