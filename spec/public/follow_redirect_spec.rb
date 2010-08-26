require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "follow_redirect!" do
  it "should request the address returned in the Location header" do
    webrat_session.response_code = 302
    webrat_session.stub!(:response_location).and_return("http://example.com/")
    webrat_session.stub!(:internal_redirect?).and_return(false)
    webrat_session.should_receive(:get).with("http://example.com/", {})
    follow_redirect!.should == 302
  end

  it "should raise an error if not redirect?" do
    lambda {
      webrat_session.response_code = 200
      follow_redirect!
    }.should raise_error("not a redirect! Got 200")
  end
end
