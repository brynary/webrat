require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "visit" do
  before do
    @session = Webrat::TestSession.new
    @session.response_body = "Hello world"
  end

  it "should use get" do
    @session.should_receive(:get).with("/", {})
    @session.visit("/")
  end
  
  it "should assert valid response" do
    @session.response_code = 501
    lambda { @session.visit("/") }.should raise_error
  end
  
  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      @session.response_code = status
      lambda { @session.visit("/") }.should_not raise_error
    end
  end
  
  it "should require a visit before manipulating page" do
    lambda { @session.fill_in "foo", :with => "blah" }.should raise_error
  end
end

describe "visit with referer" do
  before do
    @session = Webrat::TestSession.new
    @session.instance_variable_set(:@current_url, "/old_url")
    @session.response_body = "Hello world"
  end

  it "should use get with referer header" do
    @session.should_receive(:get).with("/", {}, {"HTTP_REFERER" => "/old_url"})
    @session.visit("/")
  end
  
end
