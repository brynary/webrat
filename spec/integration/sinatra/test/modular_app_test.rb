require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/../modular_app"

class MyModularAppTest < Test::Unit::TestCase
  def app
    MyModularApp.tap { |app|
      app.disable :run, :reload
      app.set :environment, :test
    }
  end

  def test_it_works
    visit "/"
    assert_contain "Hello World"
  end
end
