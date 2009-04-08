require "cgi"
require "webrat/core_extensions/blank"
require "webrat/core_extensions/nil_to_param"

require "webrat/core/elements/element"

module Webrat
  # Raised when Webrat is asked to manipulate a disabled form field
  class DisabledFieldError < WebratError
  end

  class Field < Element #:nodoc:
    attr_reader :value

    def self.xpath_search
      [".//button", ".//input", ".//textarea", ".//select"]
    end

    def self.xpath_search_excluding_hidden
      [".//button", ".//input[ @type != 'hidden']", ".//textarea", ".//select"]
    end

    def self.field_classes
      @field_classes || []
    end

    def self.inherited(klass)
      @field_classes ||= []
      @field_classes << klass
      # raise args.inspect
    end

    def self.load(session, element)
      return nil if element.nil?
      session.elements[Webrat::XML.xpath_to(element)] ||= field_class(element).new(session, element)
    end

    def self.field_class(element)
      case element.name
      when "button"   then ButtonField
      when "select"   then SelectField
      when "textarea" then TextareaField
      else
        case Webrat::XML.attribute(element, "type")
        when "checkbox" then CheckboxField
        when "hidden"   then HiddenField
        when "radio"    then RadioField
        when "password" then PasswordField
        when "file"     then FileField
        when "reset"    then ResetField
        when "submit"   then ButtonField
        when "button"   then ButtonField
        when "image"    then ButtonField
        else  TextField
        end
      end
    end

    def initialize(*args)
      super
      @value = default_value
    end

    def label_text
      return nil if labels.empty?
      labels.first.text
    end

    def id
      Webrat::XML.attribute(@element, "id")
    end

    def disabled?
      @element.attributes.has_key?("disabled") && Webrat::XML.attribute(@element, "disabled") != 'false'
    end

    def raise_error_if_disabled
      return unless disabled?
      raise DisabledFieldError.new("Cannot interact with disabled form element (#{self})")
    end

    def to_param
      return nil if disabled?

      case Webrat.configuration.mode
      when :rails
        parse_rails_request_params("#{name}=#{escaped_value}")
      when :merb
        ::Merb::Parse.query("#{name}=#{escaped_value}")
      else
        { name => escaped_value }
      end
    end

    def set(value)
      @value = value
    end

    def unset
      @value = default_value
    end

  protected

    def parse_rails_request_params(params)
      if defined?(ActionController::AbstractRequest)
        ActionController::AbstractRequest.parse_query_parameters(params)
      elsif defined?(ActionController::UrlEncodedPairParser)
        # For Rails > 2.2
        ActionController::UrlEncodedPairParser.parse_query_parameters(params)
      else
        # For Rails > 2.3
        Rack::Utils.parse_nested_query(params)
      end
    end

    def form
      Form.load(@session, form_element)
    end

    def form_element
      parent = @element.parent

      while parent.respond_to?(:parent)
        return parent if parent.name == 'form'
        parent = parent.parent
      end
    end

    def name
      Webrat::XML.attribute(@element, "name")
    end

    def escaped_value
      CGI.escape(@value.to_s)
    end

    def labels
      @labels ||= label_elements.map do |element|
        Label.load(@session, element)
      end
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
        @label_elements += Webrat::XML.xpath_search(form.element, ".//label[@for = '#{id}']")
      end

      @label_elements
    end

    def default_value
      Webrat::XML.attribute(@element, "value")
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

  class ButtonField < Field #:nodoc:

    def self.xpath_search
      [".//button", ".//input[@type = 'submit']", ".//input[@type = 'button']", ".//input[@type = 'image']"]
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
      set(Webrat::XML.attribute(@element, "value")) unless Webrat::XML.attribute(@element, "name").blank?
      form.submit
    end

  end

  class HiddenField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'hidden']"
    end

    def to_param
      if collection_name?
        super
      else
        checkbox_with_same_name = form.field_named(name, CheckboxField)

        if checkbox_with_same_name.to_param.blank?
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

  class CheckboxField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'checkbox']"
    end

    def to_param
      return nil if @value.nil?
      super
    end

    def check
      raise_error_if_disabled
      set(Webrat::XML.attribute(@element, "value") || "on")
    end

    def checked?
      Webrat::XML.attribute(@element, "checked") == "checked"
    end

    def uncheck
      raise_error_if_disabled
      set(nil)
    end

  protected

    def default_value
      if Webrat::XML.attribute(@element, "checked") == "checked"
        Webrat::XML.attribute(@element, "value") || "on"
      else
        nil
      end
    end

  end

  class PasswordField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'password']"
    end

  end

  class RadioField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'radio']"
    end

    def to_param
      return nil if @value.nil?
      super
    end

    def choose
      raise_error_if_disabled
      other_options.each do |option|
        option.set(nil)
      end

      set(Webrat::XML.attribute(@element, "value") || "on")
    end

    def checked?
      Webrat::XML.attribute(@element, "checked") == "checked"
    end

  protected

    def other_options
      form.fields.select { |f| f.name == name }
    end

    def default_value
      if Webrat::XML.attribute(@element, "checked") == "checked"
        Webrat::XML.attribute(@element, "value") || "on"
      else
        nil
      end
    end

  end

  class TextareaField < Field #:nodoc:

    def self.xpath_search
      ".//textarea"
    end

  protected

    def default_value
      Webrat::XML.inner_html(@element)
    end

  end

  class FileField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'file']"
    end

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

  class TextField < Field #:nodoc:
    def self.xpath_search
      [".//input[@type = 'text']", ".//input[not(@type)]"]
    end
  end

  class ResetField < Field #:nodoc:
    def self.xpath_search
      ".//input[@type = 'reset']"
    end
  end

  class SelectField < Field #:nodoc:

    def self.xpath_search
      ".//select"
    end

    def options
      @options ||= SelectOption.load_all(@session, @element)
    end

  protected

    def default_value
      selected_options = Webrat::XML.xpath_search(@element, ".//option[@selected = 'selected']")
      selected_options = Webrat::XML.xpath_search(@element, ".//option[position() = 1]") if selected_options.empty?

      selected_options.map do |option|
        return "" if option.nil?
        Webrat::XML.attribute(option, "value") || Webrat::XML.inner_html(option)
      end
    end

  end
end
