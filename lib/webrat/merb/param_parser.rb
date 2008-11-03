require "cgi"
gem "extlib"
require "extlib"
require "merb-core"

HashWithIndifferentAccess = Mash

module Webrat
  class ParamParser
    def self.parse_query_parameters(query_string)
      Merb::Parse.query(query_string)
    end
  end
end