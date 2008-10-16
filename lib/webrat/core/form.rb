module Webrat
  class Form
    attr_reader :element
    
    def initialize(session, element)
      @session  = session
      @element  = element
      @fields   = nil
    end

    def find_field(id_or_name_or_label, *field_types)
      possible_fields = fields_by_type(field_types)
      
      find_field_by_id(possible_fields, id_or_name_or_label)    ||
      find_field_by_name(possible_fields, id_or_name_or_label)  ||
      find_field_by_label(possible_fields, id_or_name_or_label) ||
      nil
    end
    
    def find_select_option(option_text)
      select_fields = fields_by_type([SelectField])

      select_fields.each do |select_field|
        result = select_field.find_option(option_text)
        return result if result
      end

      nil
    end

    def find_button(value = nil)
      return fields_by_type([ButtonField]).first if value.nil?
      
      possible_buttons = fields_by_type([ButtonField])
      
      possible_buttons.each do |possible_button|
        return possible_button if possible_button.matches_value?(value)
      end
      
      nil
    end

    def fields
      return @fields if @fields
      
      @fields = []
      
      (@element / "button, input, textarea, select").each do |field_element|
        @fields << Field.class_for_element(field_element).new(self, field_element)
      end
      
      @fields
    end
    
    def submit
      @session.request_page(form_action, form_method, params)
    end

  protected
  
    def find_field_by_id(possible_fields, id)
      possible_fields.each do |possible_field|
        return possible_field if possible_field.matches_id?(id)
      end
      
      nil
    end
    
    def find_field_by_name(possible_fields, name)
      possible_fields.each do |possible_field|
        return possible_field if possible_field.matches_name?(name)
      end
      
      nil
    end
    
    def find_field_by_label(possible_fields, label)      
      matching_fields = []
      
      possible_fields.each do |possible_field|
        matching_fields << possible_field if possible_field.matches_label?(label)
      end
      
      matching_fields.sort_by { |f| f.label_text.length }.first
    end
  
    def fields_by_type(field_types)
      fields.select { |f| field_types.include?(f.class) }
    end
    
    def params
      all_params = {}
      
      fields.each do |field|
        next if field.to_param.nil?
        merge(all_params, field.to_param)
      end
      
      all_params
    end
    
    def form_method
      @element["method"].blank? ? :get : @element["method"].downcase
    end
    
    def form_action
      @element["action"].blank? ? @session.current_url : @element["action"]
    end

    HASH = [Hash, HashWithIndifferentAccess] rescue [Hash]
    
    def merge(all_params, new_param)
      new_param.each do |key, value|
        case all_params[key]
        when *HASH
          merge_hash_values(all_params[key], value)
        when Array
          all_params[key] += value
        else
          all_params[key] = value
        end
      end
    end
  
    def merge_hash_values(a, b) # :nodoc:
      a.keys.each do |k|
        if b.has_key?(k)
          case [a[k], b[k]].map(&:class)
          when [Hash, Hash]
            a[k] = merge_hash_values(a[k], b[k])
            b.delete(k)
          when [Array, Array]
            a[k] += b[k]
            b.delete(k)
          end
        end
      end
      a.merge!(b)
    end
    
  end
end