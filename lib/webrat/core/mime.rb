module Webrat #:nodoc:
  module MIME #:nodoc:
    MIME_TYPES = Rack::Mime::MIME_TYPES.dup.merge(
      ".multipart_form"   => "multipart/form-data",
      ".url_encoded_form" => "application/x-www-form-urlencoded"
    ).freeze

    def mime_type(type)
      return type if type.nil? || type.to_s.include?("/")
      type = ".#{type}" unless type.to_s[0] == ?.
      MIME_TYPES.fetch(type) { |type|
        raise ArgumentError.new("Invalid Mime type: #{type}")
      }
    end

    module_function :mime_type
  end
end
