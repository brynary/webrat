require "rubygems"
require "test/unit"
require "rack/test"
# require "redgreen"

require File.dirname(__FILE__) + "/../../../../lib/webrat"

Webrat.configure do |config|
  config.mode = :rack_test
end

class Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    RackApp.new
  end
end
