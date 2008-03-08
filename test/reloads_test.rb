require File.dirname(__FILE__) + "/helper"

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

class ReloadsTest < Test::Unit::TestCase

  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @response = mock
    @session.stubs(:response).returns(@response)
    @response.stubs(:body).returns("")
  end

  def test_should_reload_the_page
    @session.expects(:get_via_redirect).with("/", {}).times(2)
    @session.visits("/")
    @session.reloads
  end

  def test_should_not_request_page_if_not_visited_any_page
    @session.expects(:get_via_redirect).never
    @session.reloads
  end
end
