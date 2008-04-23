require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

describe "visits" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @response = mock
    @session.stubs(:response).returns(@response)
    @response.stubs(:body).returns("")
  end

  it "should_use_get" do
    @session.expects(:get_via_redirect).with("/", {})
    @session.visits("/")
  end
  
  it "should_assert_valid_response" do
    @session.expects(:assert_response).with(:success)
    @session.visits("/")
  end
  
  it "should_require_a_visit_before_manipulating_page" do
    lambda { @session.fills_in "foo", :with => "blah" }.should raise_error
  end
end
