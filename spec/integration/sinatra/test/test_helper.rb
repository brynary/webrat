require "test/unit"
# require "redgreen"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../../../lib"
require "webrat"

Webrat.configure do |config|
  config.mode = :sinatra
end

class Test::Unit::TestCase
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body
end
