require "webrat/core/field"
require "webrat/core_extensions/blank"

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
      possible_buttons.detect { |possible_button| possible_button.matches_id?(value) } ||
      possible_buttons.detect { |possible_button| possible_button.matches_value?(value) }
    end

    def fields
      return @fields if @fields
      
      @fields = (@element / "button, input, textarea, select").collect do |field_element|
        Field.class_for_element(field_element).new(self, field_element)
      end
    end
    
    def submit
      @session.request_page(form_action, form_method, params)
    end

  protected
  
    def find_field_by_id(possible_fields, id)
      possible_fields.detect { |possible_field| possible_field.matches_id?(id) }
    end
    
    def find_field_by_name(possible_fields, name)
      possible_fields.detect { |possible_field| possible_field.matches_name?(name) }
    end
    
    def find_field_by_label(possible_fields, label)      
      matching_fields = possible_fields.select do |possible_field|
        possible_field.matches_label?(label)
      end      
      matching_fields.min { |a, b| a.label_text.length <=> b.label_text.length }
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
          case [a[k], b[k]].map{|value| value.class}
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