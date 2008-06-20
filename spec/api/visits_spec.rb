require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "visits" do
  before do
    @session = Webrat::TestSession.new
    @session.response_body = "Hello world"
  end

  it "should use get" do
    @session.expects(:get).with("/", {})
    @session.visits("/")
  end
  
  it "should assert valid response" do
    @session.response_code = 404
    lambda { @session.visits("/") }.should raise_error
  end
  
  it "should require a visit before manipulating page" do
    lambda { @session.fills_in "foo", :with => "blah" }.should raise_error
  end
end
