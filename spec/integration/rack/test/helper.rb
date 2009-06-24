require "rubygems"
require "test/unit"
require "rack/test"
# require "redgreen"

require File.dirname(__FILE__) + "/../../../../lib/webrat"
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
