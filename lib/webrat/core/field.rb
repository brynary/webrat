module Webrat
  class Field
    
    def self.class_for_element(element)
      if element.name == "input"
        if %w[submit image].include?(element["type"])
          field_class = "button"
        else
          field_class = element["type"] || "text"
        end
      else
        field_class = element.name
      end
      
      Webrat.const_get("#{field_class.capitalize}Field")
    rescue NameError
      raise "Invalid field element: #{element.inspect}"
    end
    
    def initialize(form, element)
      @form     = form
      @element  = element
      
      @value    = default_value
    end

    def label_text
      return nil if labels.empty?
      labels.first.text
    end
    
    def matches_id?(id)
      @element["id"] == id.to_s
    end
    
    def matches_name?(name)
      @element["name"] == name.to_s
    end
    
    def matches_label?(label_text)
      return false if labels.empty?
      labels.any? { |label| label.matches_text?(label_text) }
    end
    
    def matches_alt?(alt)
      @element["alt"] =~ /^\W*#{Regexp.escape(alt.to_s)}/i
    end

    def disabled?
      !@element["disabled"].nil? && @element["disabled"] != 'false'
    end
    
    def raise_error_if_disabled
      raise "Cannot interact with disabled form element (#{self})" if disabled?
    end
        
    def to_param
      value = @value.to_s.gsub('&', '%26')
      param_parser.parse_query_parameters("#{name}=#{value}")
    end
    
    def set(value)
      @value = value
    end
    
    def unset
      @value = default_value
    end
    
  protected
  
    def id
      @element["id"]
    end
    
    def name
      @element["name"]
    end
    
    def labels
      @labels ||= label_elements.map { |element| Label.new(self, element) }
    end
    
    def label_elements
      return @label_elements unless @label_elements.nil?
      @label_elements = []

      parent = @element.parent
      while parent.respond_to?(:parent)
        if parent.name == 'label'
          @label_elements.push parent
          break
        end
        parent = parent.parent
      end

      unless id.blank?
        @label_elements += @form.element / "label[@for=#{id}]"
      end

      @label_elements
    end
    
    def default_value
      @element["value"]
    end
    
    def param_parser
      if defined?(CGIMethods)
        CGIMethods
      else
        require "action_controller"
        require "action_controller/integration"
        ActionController::AbstractRequest
      end
    end
    
    def replace_param_value(params, oval, nval)
      output = Hash.new
      params.each do |key, value|
        case value
        when Hash
          value = replace_param_value(value, oval, nval)
        when Array
          value = value.map { |o| o == oval ? nval : oval }
        when oval
          value = nval
        end
        output[key] = value
      end
      output
    end
  end
  
  class ButtonField < Field

    def matches_text?(text)
      @element.innerHTML =~ /#{Regexp.escape(text.to_s)}/i
    end

    def matches_value?(value)
      @element["value"] =~ /^\W*#{Regexp.escape(value.to_s)}/i || matches_text?(value) || matches_alt?(value)
    end

    def to_param
      return nil if @value.nil?
      super
    end

    def default_value
      nil
    end

    def click
      raise_error_if_disabled
      set(@element["value"]) unless @element["name"].blank?
      @form.submit
    end

  end

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

  class CheckboxField < Field

    def to_param
      return nil if @value.nil?
      super
    end

    def check
      raise_error_if_disabled
      set(@element["value"] || "on")
    end

    def uncheck
      raise_error_if_disabled
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

  class PasswordField < Field
  end

  class RadioField < Field

    def to_param
      return nil if @value.nil?
      super
    end
    
    def choose
      raise_error_if_disabled
      other_options.each do |option|
        option.set(nil)
      end
      
      set(@element["value"] || "on")
    end
    
  protected

    def other_options
      @form.fields.select { |f| f.name == name }
    end
    
    def default_value
      if @element["checked"] == "checked"
        @element["value"] || "on"
      else
        nil
      end
    end

  end

  class TextareaField < Field

  protected

    def default_value
      @element.inner_html
    end

  end
  
  class FileField < Field

    attr_accessor :content_type

    def set(value, content_type = nil)
      super(value)
      @content_type = content_type
    end

    def to_param
      if @value.nil?
        super
      else
        replace_param_value(super, @value, test_uploaded_file)
      end
    end
    
  protected
  
    def test_uploaded_file
      if content_type
        ActionController::TestUploadedFile.new(@value, content_type)
      else
        ActionController::TestUploadedFile.new(@value)
      end
    end

  end

  class TextField < Field
  end

  class ResetField < Field
  end

  class SelectField < Field

    def find_option(text)
      options.detect { |o| o.matches_text?(text) }
    end

  protected

    def default_value
      selected_options = @element / "option[@selected='selected']"
      selected_options = @element / "option:first" if selected_options.empty? 
      selected_options.map do |option|
        return "" if option.nil?
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
