require File.expand_path(File.join(File.dirname(__FILE__), "field"))

module Webrat
  class HiddenField < Field
    
    def to_param
      if collection_name?
        super
      else
        checkbox_with_same_name = @form.find_field(name, CheckboxField)

        if checkbox_with_same_name.to_param.nil?
          super
        else
          nil
        end
      end
    end
    
  protected
  
    def collection_name?
      name =~ /\[\]/
    end
    
  end
end