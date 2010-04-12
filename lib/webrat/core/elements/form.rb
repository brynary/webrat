require "webrat/core/elements/field"
require "webrat/core_extensions/blank"

require "webrat/core/elements/element"
require "webrat/core/locators/field_named_locator"

module Webrat
  class Form < Element #:nodoc:
    attr_reader :element

    def self.xpath_search
      [".//form"]
    end

    def fields
      @fields ||= Field.load_all(@session, @element)
    end

    def submit
      @session.request_page(form_action, form_method, params)
    end

    def field_named(name, *field_types)
      Webrat::Locators::FieldNamedLocator.new(@session, dom, name, *field_types).locate
    end

  protected

    def dom
      @session.dom.xpath(path).first
    end

    def fields_by_type(field_types)
      if field_types.any?
        fields.select { |f| field_types.include?(f.class) }
      else
        fields
      end
    end

    # iterate over all form fields to build a request querystring to get params from it,
    # for file_field we made a work around to pass a digest as value to later replace it
    # in params hash with the real file.
    def params
      query_string = []
      replaces = {}

      fields.each do |field|
        next if field.to_query_string.nil?
        replaces.merge!({field.digest_value => field.test_uploaded_file}) if field.is_a?(FileField)
        query_string << field.to_query_string
      end

      query_params = self.class.query_string_to_params(query_string.join('&'))

      query_params = self.class.replace_params_values(query_params, replaces)

      self.class.unescape_params(query_params)
    end

    def form_method
      @element["method"].blank? ? :get : @element["method"].downcase
    end

    def form_action
      @element["action"].blank? ? @session.current_url : @element["action"]
    end

    def self.replace_param_value(params, oval, nval)
      output = Hash.new
      params.each do |key, value|
        case value
        when Hash
          value = replace_param_value(value, oval, nval)
        when Array
          value = value.map { |o| o == oval ? nval : ( o.is_a?(Hash) ? replace_param_value(o, oval, nval) : o) }
        when oval
          value = nval
        end
        output[key] = value
      end
      output
    end

    def self.replace_params_values(params, values)
      values.each do |key, value|
        params = replace_param_value(params, key, value)
      end
      params
    end

    def self.unescape_params(params)
      case params.class.name
      when 'Hash', 'Mash'
        params.each { |key,value| params[key] = unescape_params(value) }
        params
      when 'Array'
        params.collect { |value| unescape_params(value) }
      else
        params.is_a?(String) ? CGI.unescapeHTML(params) : params
      end
    end

    def self.query_string_to_params(query_string)
      case Webrat.configuration.mode
      when :rails
        parse_rails_request_params(query_string)
      when :merb
        ::Merb::Parse.query(query_string)
      when :rack, :sinatra
        Rack::Utils.parse_nested_query(query_string)
      else
        query_string.split('&').map {|query| { query.split('=').first => query.split('=').last }}
      end
    end

    def self.parse_rails_request_params(query_string)
      if defined?(ActionController::AbstractRequest)
        ActionController::AbstractRequest.parse_query_parameters(query_string)
      elsif defined?(ActionController::UrlEncodedPairParser)
        ActionController::UrlEncodedPairParser.parse_query_parameters(query_string)
      else
        Rack::Utils.parse_nested_query(query_string)
      end
    end
  end
end
