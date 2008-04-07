require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class TextareaField < Field
  
  protected
  
    def default_value
      @element.inner_html
    end
    
  end
end