require "cgi"

module Webrat
  class ParamParser
    def self.parse_query_parameters(query_string)
      return {} if query_string.blank?

      pairs = query_string.split('&').collect do |chunk|
        next if chunk.empty?
        key, value = chunk.split('=', 2)
        next if key.empty?
        value = value.nil? ? nil : CGI.unescape(value)
        [ CGI.unescape(key), value ]
      end.compact

      UrlEncodedPairParser.new(pairs).result
    end
  end
end