require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class CheckboxField < Field
    
    def to_param
      return nil if @value.nil?
      super
    end
    
    def check
      set(@element["value"] || "on")
    end
    
    def uncheck
      set(nil)
    end
    
  protected
  
    def default_value
      if @element["checked"] == "checked"
        @element["value"] || "on"
      else
        nil
      end
    end

  end
end