require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/../modular_app"

class MyModularAppTest < Test::Unit::TestCase
  def app
    MyModularApp
  end

  def test_it_works
    visit "/"
    assert_contain "Hello World"
  end

  def test_redirects
    visit "/redirect_absolute_url"
    assert_equal "spam", response_body
  end
end
