require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Webrat::RailsSession do
  it "should delegate response_body to the session response body" do
    response = mock("response", :body => "<html>")
    integration_session = mock("integration session", :response => response)
    Webrat::RailsSession.new(integration_session).response_body.should == "<html>"
  end
  
  it "should delegate response_code to the session response code" do
    response = mock("response", :code => "42")
    integration_session = mock("integration session", :response => response)
    Webrat::RailsSession.new(integration_session).response_code.should == 42
  end
  
  it "should delegate get to request_via_redirect on the integration session" do
    integration_session = mock("integration session")
    rails_session = Webrat::RailsSession.new(integration_session)
    integration_session.should_receive(:request_via_redirect).with(:get, "url", "data", "headers")
    rails_session.get("url", "data", "headers")
  end
  
  it "should delegate post to request_via_redirect on the integration session" do
    integration_session = mock("integration session")
    rails_session = Webrat::RailsSession.new(integration_session)
    integration_session.should_receive(:request_via_redirect).with(:post, "url", "data", "headers")
    rails_session.post("url", "data", "headers")
  end
  
  it "should delegate put to request_via_redirect on the integration session" do
    integration_session = mock("integration session")
    rails_session = Webrat::RailsSession.new(integration_session)
    integration_session.should_receive(:request_via_redirect).with(:put, "url", "data", "headers")
    rails_session.put("url", "data", "headers")
  end
  
  it "should delegate delete to request_via_redirect on the integration session" do
    integration_session = mock("integration session")
    rails_session = Webrat::RailsSession.new(integration_session)
    integration_session.should_receive(:request_via_redirect).with(:delete, "url", "data", "headers")
    rails_session.delete("url", "data", "headers")
  end
  
  context "the URL is a full path" do
    it "should just pass on the path" do
      integration_session = mock("integration session", :https! => nil)
      rails_session = Webrat::RailsSession.new(integration_session)
      integration_session.should_receive(:request_via_redirect).with(:get, "/url", "data", "headers")
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end
  
  context "the URL is https://" do
    it "should call #https! with true before the request and just pass on the path" do
      integration_session = mock("integration session")
      rails_session = Webrat::RailsSession.new(integration_session)
      integration_session.should_receive(:https!).with(true)
      integration_session.should_receive(:request_via_redirect).with(:get, "/url", "data", "headers")
      rails_session.get("https://www.example.com/url", "data", "headers")
    end
  end
  
  context "the URL is http://" do
    it "should call #https! with true before the request" do
      integration_session = mock("integration session", :request_via_redirect => nil)
      rails_session = Webrat::RailsSession.new(integration_session)
      integration_session.should_receive(:https!).with(false)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end
  
  context "the URL include an anchor" do
    it "should strip out the anchor" do
      integration_session = mock("integration session", :https! => false)
      rails_session = Webrat::RailsSession.new(integration_session)
      integration_session.should_receive(:request_via_redirect).with(:get, "/url", "data", "headers")
      rails_session.get("http://www.example.com/url#foo", "data", "headers")
    end
  end
  
  it "should provide a saved_page_dir" do
    Webrat::RailsSession.new(mock("integration session")).should respond_to(:saved_page_dir)
  end
  
  it "should provide a doc_root" do
    Webrat::RailsSession.new(mock("integration session")).should respond_to(:doc_root)
  end
end