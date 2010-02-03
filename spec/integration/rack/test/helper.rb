require "test/unit"
require "rack/test"
# require "redgreen"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../../../lib"
require "webrat"
require File.dirname(__FILE__) + "/../app"

Webrat.configure do |config|
  config.mode = :rack
end

class Test::Unit::TestCase
  def app
    Rack::Builder.new {
      use Rack::Lint
      run RackApp.new
    }
  end
end
