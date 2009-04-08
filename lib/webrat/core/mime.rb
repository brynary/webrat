module Webrat #:nodoc:
  module MIME #:nodoc:

    def self.mime_type(string_or_symbol) #:nodoc:
      if string_or_symbol.is_a?(String)
        string_or_symbol
      else
        case string_or_symbol
        when :text              then "text/plain"
        when :html              then "text/html"
        when :js                then "text/javascript"
        when :css               then "text/css"
        when :ics               then "text/calendar"
        when :csv               then "text/csv"
        when :xml               then "application/xml"
        when :rss               then "application/rss+xml"
        when :atom              then "application/atom+xml"
        when :yaml              then "application/x-yaml"
        when :multipart_form    then "multipart/form-data"
        when :url_encoded_form  then "application/x-www-form-urlencoded"
        when :json              then "application/json"
        else
          raise ArgumentError.new("Invalid Mime type: #{string_or_symbol.inspect}")
        end
      end
    end

  end
end
