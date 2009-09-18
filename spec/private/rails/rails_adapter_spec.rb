require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Webrat::RailsAdapter do
  before :each do
    Webrat.configuration.mode = :rails
    @integration_session = mock("integration_session")
  end

  it "should delegate response_body to the session response body" do
    @integration_session.stub!(:response => mock("response", :body => "<html>"))
    Webrat::RailsAdapter.new(@integration_session).response_body.should == "<html>"
  end

  it "should delegate response_code to the session response code" do
    @integration_session.stub!(:response => mock("response", :code => "42"))
    Webrat::RailsAdapter.new(@integration_session).response_code.should == 42
  end

  it "should delegate get to the integration session" do
    @integration_session.should_receive(:get).with("url", "data", "headers")
    rails_session = Webrat::RailsAdapter.new(@integration_session)
    rails_session.get("url", "data", "headers")
  end

  it "should delegate post to the integration session" do
    @integration_session.should_receive(:post).with("url", "data", "headers")
    rails_session = Webrat::RailsAdapter.new(@integration_session)
    rails_session.post("url", "data", "headers")
  end

  it "should delegate put to the integration session" do
    @integration_session.should_receive(:put).with("url", "data", "headers")
    rails_session = Webrat::RailsAdapter.new(@integration_session)
    rails_session.put("url", "data", "headers")
  end

  it "should delegate delete to the integration session" do
    @integration_session.should_receive(:delete).with("url", "data", "headers")
    rails_session = Webrat::RailsAdapter.new(@integration_session)
    rails_session.delete("url", "data", "headers")
  end

  context "the URL is a full path" do
    it "should pass the full url" do
      @integration_session.stub!(:https!)
      @integration_session.should_receive(:get).with("http://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsAdapter.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is https://" do
    it "should call #https! with true before the request before passing along the full url" do
      @integration_session.should_receive(:https!).with(true)
      @integration_session.should_receive(:get).with("https://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsAdapter.new(@integration_session)
      rails_session.get("https://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is http://" do
    it "should call #https! with true before the request" do
      @integration_session.stub!(:get)
      @integration_session.should_receive(:https!).with(false)
      rails_session = Webrat::RailsAdapter.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  context "the URL include an anchor" do
    it "should strip out the anchor" do
      @integration_session.should_receive(:https!).with(false)
      @integration_session.should_receive(:get).with("http://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsAdapter.new(@integration_session)
      rails_session.get("http://www.example.com/url#foo", "data", "headers")
    end
  end

  it "should provide a saved_page_dir" do
    Webrat::RailsAdapter.new(mock("integration session")).should respond_to(:saved_page_dir)
  end

  it "should provide a doc_root" do
    Webrat::RailsAdapter.new(mock("integration session")).should respond_to(:doc_root)
  end
end
