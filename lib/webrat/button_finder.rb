require File.expand_path(File.join(File.dirname(__FILE__), "field_finder"))

module Webrat
  class ButtonFinder < FieldFinder
    def initialize(root, name = nil)
      @root                 = root
      @id_or_name_or_label  = name
      @element_types        = %w[input]
      @input_types          = %w[submit image]
      
      @candidates = nil
    end
    
    def find
      if @id_or_name_or_label.nil?
        candidates.first
      else
        find_by_id(@id_or_name_or_label) ||
        find_by_name ||
        find_by_value
      end
    end
    
  protected
  
    def find_by_value
      candidates.detect { |el| el.attributes["value"] == @id_or_name_or_label }
    end
  end
end