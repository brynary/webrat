require "rubygems"
require "test/unit"
require "rack/test"
# require "redgreen"

require File.dirname(__FILE__) + "/../../../../lib/webrat"

Webrat.configure do |config|
  config.mode = :rack
end

class Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    Rack::Builder.new {
      use Rack::Lint
      run RackApp.new
    }
  end
end
