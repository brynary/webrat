require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class ButtonField < Field
    
    def matches_value?(value)
      @element["value"] =~ /^\W*#{value}\b/i
    end
    
    def to_param
      return nil if @value.nil?
      super
    end
    
    def default_value
      nil
    end
    
    def click
      set(@element["value"]) unless @element["name"].blank?
      @form.submit
    end
    
  end
end