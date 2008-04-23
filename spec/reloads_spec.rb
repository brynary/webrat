require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

describe "reloads" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @response = mock
    @session.stubs(:response).returns(@response)
    @response.stubs(:body).returns("")
  end

  it "should_reload_the_page" do
    @session.expects(:get_via_redirect).with("/", {}).times(2)
    @session.visits("/")
    @session.reloads
  end

  it "should_not_request_page_if_not_visited_any_page" do
    @session.expects(:get_via_redirect).never
    @session.reloads
  end
end
