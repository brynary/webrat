module Webrat
  class FieldFinder
    def initialize(root, id_or_name_or_label, element_types, input_types = nil)
      @root                 = root
      @id_or_name_or_label  = id_or_name_or_label.to_s
      @element_types        = Array(element_types)
      @input_types          = Array(input_types)
      
      @candidates = nil
    end
    
    def find
      find_by_id(@id_or_name_or_label) ||
      find_by_name ||
      find_by_label
    end
    
  protected
  
    # def find_select_list_by_name_or_label(name_or_label) # :nodoc:
    #   select = find_element_by_name("select", name_or_label)
    #   return select if select
    # 
    #   label = find_form_label(name_or_label)
    #   label ? field_for_label(label) : nil
    # end
    #   
    # def find_option_by_value(option_value, select=nil) # :nodoc:
    #   options = select.nil? ? (dom / "option") : (select / "option")
    #   options.detect { |el| el.innerHTML == option_value }
    # end
  
    def field_for_label(label)
      inputs_within_label = canidates_within(label)
      
      if inputs_within_label.any?
        inputs_within_label.first 
      else
        find_by_id(label.attributes["for"])
      end
    end
  
    def find_by_id(id)
      candidates.detect { |el| el.attributes["id"] == id }
    end
    
    def find_by_name
      candidates.detect { |el| el.attributes["name"] == @id_or_name_or_label }
    end
    
    def find_by_label
      label = canididate_labels.sort_by { |el| el.innerText.strip.size }.first
      label ? field_for_label(label) : nil
    end
    
    def canididate_labels
      (@root / "label").select { |el| el.innerText =~ /^\W*#{Regexp.escape(@id_or_name_or_label)}\b/i }
    end
    
    def candidates
      return @candidates if @candidates
      @candidates = canidates_within(@root)
    end
    
    def canidates_within(root)
      candidates = []
      
      @element_types.each do |element_type|
        if "input" == element_type && @input_types.any?
          @input_types.each do |input_type|
            candidates += (root / "input[@type=#{input_type}]")
          end
        else
          candidates += (root / element_type)
        end
      end
      
      candidates
    end
    
  end
end