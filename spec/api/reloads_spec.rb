require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "reloads" do
  before do
    @session = Webrat::TestSession.new
    @session.response_body = "Hello world"
  end

  it "should reload the page with http referer" do
    @session.should_receive(:get).with("/", {})
    @session.should_receive(:get).with("/", {}, {"HTTP_REFERER"=>"/"})
    @session.visits("/")
    @session.reloads
  end
end
