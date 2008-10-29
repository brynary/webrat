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
  
  it "should matches_text? on regexp" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return("Link Text")
    link.matches_text?(/link/i).should == 0
  end
  
  it "should matches_text? on link_text" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return("Link Text")
    link.matches_text?("Link Text").should == 0
  end
  
  it "should not matches_text? on link_text case insensitive" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return("Link Text")
    link.should_receive(:title).and_return(nil)
    link.matches_text?("link_text").should == false
  end
  
  it "should match text including &nbsp;" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return("Link&nbsp;Text")
    link.matches_text?("Link Text").should == 0
  end
  
  it "should not matches_text? on wrong text" do 
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return("Some Other Link")
    link.should_receive(:title).and_return(nil)
    link.matches_text?("Link Text").should == false
  end
  
  it "should matches_id? on exact matching id" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("some_id")
    link.matches_id?("some_id").should == true
  end
  
  it "should not matches_id? on incorrect id" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("other_id")
    link.matches_id?("some_id").should == false
  end
  
  it "should matches_id? on matching id by regexp" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("some_id")
    link.matches_id?(/some/).should == true
  end
  
end