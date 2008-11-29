require "webrat/core/field"
require "webrat/core_extensions/blank"

module Webrat
  class Form #:nodoc:
    attr_reader :element
    
    def self.css_search
      "form"
    end
    
    def initialize(session, element)
      @session  = session
      @element  = element
      @fields   = nil
    end
    
    def field_by_element(element, *field_types)
      return nil if element.nil?
      
      expected_path = Webrat::XML.xpath_to(element)
      
      fields_by_type(field_types).detect do |possible_field|
        possible_field.path == expected_path
      end
    end
    
    def find_select_option(option_text)
      select_fields = fields_by_type([SelectField])

      select_fields.each do |select_field|
        result = select_field.find_option(option_text)
        return result if result
      end

      nil
    end

    def fields
      return @fields if @fields
      
      @fields = []
      
      [SelectField, TextareaField, ButtonField, CheckboxField, PasswordField,
       RadioField, FileField, ResetField, TextField, HiddenField].each do |field_class|
        @fields += Webrat::XML.xpath_search(@element, *field_class.xpath_search).map do |element| 
          field_class.new(self, element)
        end
      end
      
      @fields
    end
    
    def labels
      @labels ||= Webrat::XML.css_search(element, "label").map { |element| Label.new(nil, element) }
    end
    
    def submit
      @session.request_page(form_action, form_method, params)
    end
    
    def field_named(name, *field_types)
      possible_fields = fields_by_type(field_types)
      possible_fields.detect { |possible_field| possible_field.matches_name?(name) }
    end
    
    def field_labeled(label, *field_types)
      possible_fields = fields_by_type(field_types)      
      matching_fields = possible_fields.select do |possible_field|
        possible_field.matches_label?(label)
      end      
      matching_fields.min { |a, b| a.label_text.length <=> b.label_text.length }
    end

    def label_matching(label_text)
      labels.detect { |label| label.matches_text?(label_text) }
    end
    
    def matches_id?(id)
      Webrat::XML.attribute(@element, "id") == id.to_s
    end
    
  protected
  
    def fields_by_type(field_types)
      if field_types.any?
        fields.select { |f| field_types.include?(f.class) }
      else
        fields
      end
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
      Webrat::XML.attribute(@element, "method").blank? ? :get : Webrat::XML.attribute(@element, "method").downcase
    end
    
    def form_action
      Webrat::XML.attribute(@element, "action").blank? ? @session.current_url : Webrat::XML.attribute(@element, "action")
    end
    
    def merge(all_params, new_param)
      new_param.each do |key, value|
        case all_params[key]
        when *hash_classes
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
          when *hash_classes.zip(hash_classes)
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
    
    def hash_classes
      klasses = [Hash]
      
      case Webrat.configuration.mode
      when :rails
        klasses << HashWithIndifferentAccess
      when :merb
        klasses << Mash
      end
      
      klasses
    end
    
  end
end
