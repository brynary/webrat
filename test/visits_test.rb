require File.dirname(__FILE__) + "/helper"

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

class VisitsTest < Test::Unit::TestCase

  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @response = mock
    @session.stubs(:response).returns(@response)
    @response.stubs(:body).returns("")
  end

  def test_should_use_get
    @session.expects(:get_via_redirect).with("/", {})
    @session.visits("/")
  end
  
  def test_should_assert_valid_response
    @session.expects(:assert_response).with(:success)
    @session.visits("/")
  end
  
  def test_should_require_a_visit_before_manipulating_page
    assert_raise(RuntimeError) do
      @session.fills_in "foo", :with => "blah"
    end
  end
end
