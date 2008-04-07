require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class RadioField < Field
    
  protected
  
    def default_value
      if @element["checked"] == "checked"
        @element["value"]
      else
        nil
      end
    end
  
  end
end