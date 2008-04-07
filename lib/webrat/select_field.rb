require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class SelectField < Field
    
    def find_option(text)
      options.detect { |o| o.matches_text?(text) }
    end
    
  protected
  
    def default_value
      selected_options = @element / "option[@selected='selected']"
      selected_options = @element / "option:first" if selected_options.empty? 
      selected_options.map do |option|
        option["value"] || option.innerHTML
      end
    end
   
    def options
      option_elements.map { |oe| SelectOption.new(self, oe) }
    end
    
    def option_elements
      (@element / "option")
    end
    
  end
end