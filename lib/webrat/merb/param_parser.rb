module Webrat
  class MerbParamParser
    def self.parse_query_parameters(query_string)
      Merb::Parse.query(query_string)
    end
  end
end