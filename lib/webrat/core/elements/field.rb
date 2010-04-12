require "cgi"
require "digest/md5"
require "webrat/core_extensions/blank"
require "webrat/core_extensions/nil_to_query_string"

require "webrat/core/elements/element"

module Webrat
  # Raised when Webrat is asked to manipulate a disabled form field
  class DisabledFieldError < WebratError
  end

  class Field < Element #:nodoc:
    attr_reader :value

    def self.xpath_search
      ".//button|.//input|.//textarea|.//select"
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
      session.elements[element.path] ||= field_class(element).new(session, element)
    end

    def self.field_class(element)
      case element.name
      when "button"   then ButtonField
      when "select"
        if element.attributes["multiple"].nil?
          SelectField
        else
          MultipleSelectField
        end
      when "textarea" then TextareaField
      else
        case element["type"]
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
      @element["id"]
    end

    def disabled?
      @element.attributes.has_key?("disabled") && @element["disabled"] != 'false'
    end

    def raise_error_if_disabled
      return unless disabled?
      raise DisabledFieldError.new("Cannot interact with disabled form element (#{self})")
    end

    def to_query_string
      return nil if disabled?

      query_string = case Webrat.configuration.mode
      when :rails, :merb, :rack, :sinatra
        build_query_string
      when :mechanize
        build_query_string(false)
      end

      query_string
    end

    def set(value)
      @value = value
    end

    def unset
      @value = default_value
    end

  protected

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
      @element["name"]
    end

    def build_query_string(escape_value=true)
      if @value.is_a?(Array)
        @value.collect {|value| "#{name}=#{ escape_value ? escape(value) : value }" }.join("&")
      else
        "#{name}=#{ escape_value ? escape(value) : value }"
      end
    end

    def escape(value)
      CGI.escape(value.to_s)
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
        @label_elements += form.element.xpath(".//label[@for = '#{id}']")
      end

      @label_elements
    end

    def default_value
      @element["value"]
    end
  end

  class ButtonField < Field #:nodoc:

    def self.xpath_search
      [".//button", ".//input[@type = 'submit']", ".//input[@type = 'button']", ".//input[@type = 'image']"]
    end

    def to_query_string
      return nil if @value.nil?
      super
    end

    def default_value
      nil
    end

    def click
      raise_error_if_disabled
      set(@element["value"]) unless @element["name"].blank?
      form.submit
    end

  end

  class HiddenField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'hidden']"
    end

    def to_query_string
      if collection_name?
        super
      else
        checkbox_with_same_name = form.field_named(name, CheckboxField)

        if checkbox_with_same_name.to_query_string.blank?
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

    def to_query_string
      return nil if @value.nil?
      super
    end

    def check
      raise_error_if_disabled
      set(@element["value"] || "on")
    end

    def checked?
      @element["checked"] == "checked"
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

  class PasswordField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'password']"
    end

  end

  class RadioField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'radio']"
    end

    def to_query_string
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

    def checked?
      @element["checked"] == "checked"
    end

  protected

    def other_options
      form.fields.select { |f| f.name == name }
    end

    def default_value
      if @element["checked"] == "checked"
        @element["value"] || "on"
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
      @element.inner_html
    end

  end

  class FileField < Field #:nodoc:

    def self.xpath_search
      ".//input[@type = 'file']"
    end

    attr_accessor :content_type

    def set(value, content_type = nil)
      @original_value = @value
      @content_type ||= content_type
      super(value)
    end

    def digest_value
      @value ? Digest::MD5.hexdigest(self.object_id.to_s) : ""
    end

    def to_query_string
      @value.nil? ? set("") : set(digest_value)
      super
    end

    def test_uploaded_file
      return "" if @original_value.blank?

      case Webrat.configuration.mode
      when :rails
        if content_type
          ActionController::TestUploadedFile.new(@original_value, content_type)
        else
          ActionController::TestUploadedFile.new(@original_value)
        end
      when :rack, :merb
        Rack::Test::UploadedFile.new(@original_value, content_type)
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
      [".//input[@type = 'reset']"]
    end
  end

  class SelectField < Field #:nodoc:

    def self.xpath_search
      [".//select[not(@multiple)]"]
    end

    def options
      @options ||= SelectOption.load_all(@session, @element)
    end

    def unset(value)
      @value = nil
    end

  protected

    def default_value
      selected_options = @element.xpath(".//option[@selected = 'selected']")
      selected_options = @element.xpath(".//option[position() = 1]") if selected_options.empty?

      selected_options.map do |option|
        return "" if option.nil?
        option["value"] || option.inner_html
      end.uniq.first
    end

  end

  class MultipleSelectField < Field #:nodoc:

    def self.xpath_search
      [".//select[@multiple='multiple']"]
    end

    def options
      @options ||= SelectOption.load_all(@session, @element)
    end

    def set(value)
      @value << value
    end

    def unset(value)
      @value.delete(value)
    end

  protected

    # Overwrite SelectField definition because we don't want to select the first option
    # (mutliples don't select the first option unlike their non multiple versions)
    def default_value
      selected_options = @element.xpath(".//option[@selected = 'selected']")

      selected_options.map do |option|
        return "" if option.nil?
        option["value"] || option.inner_html
      end.uniq
    end

  end

end
