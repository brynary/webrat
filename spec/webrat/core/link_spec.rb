require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Link do
#  include Webrat::Link

  before do
    @session = mock(Webrat::TestSession)
  end
  
  it "should pass through relative urls" do
    link = Webrat::Link.new(@session, {"href" => "/path"})
    @session.should_receive(:request_page).with("/path", :get, {})
    link.click
  end
  
  it "shouldnt put base url onto " do
    url = "https://www.example.com/path"
    @session.should_receive(:request_page).with(url, :get, {})
    link = Webrat::Link.new(@session, {"href" => url})
    link.click
  end
  
end