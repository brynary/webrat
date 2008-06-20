require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "reloads" do
  before do
    @session = Webrat::TestSession.new
    @session.response_body = "Hello world"
  end

  it "should reload the page" do
    @session.expects(:get).with("/", {}).times(2)
    @session.visits("/")
    @session.reloads
  end
end
