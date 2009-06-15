require "rubygems"
require "test/unit"
# require "redgreen"

require File.dirname(__FILE__) + "/../../../../lib/webrat"

Webrat.configure do |config|
  config.mode = :sinatra
end

class Test::Unit::TestCase
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body
end
