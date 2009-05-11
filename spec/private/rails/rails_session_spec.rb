require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "webrat/rails"

describe Webrat::RailsSession do
  before :each do
    Webrat.configuration.mode = :rails
    @integration_session = mock("integration_session")
  end

  it "should delegate response_body to the session response body" do
    @integration_session.stub!(:response => mock("response", :body => "<html>"))
    Webrat::RailsSession.new(@integration_session).response_body.should == "<html>"
  end

  it "should delegate response_code to the session response code" do
    @integration_session.stub!(:response => mock("response", :code => "42"))
    Webrat::RailsSession.new(@integration_session).response_code.should == 42
  end

  it "should delegate get to the integration session" do
    @integration_session.should_receive(:get).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.get("url", "data", "headers")
  end

  it "should delegate post to the integration session" do
    @integration_session.should_receive(:post).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.post("url", "data", "headers")
  end

  it "should delegate put to the integration session" do
    @integration_session.should_receive(:put).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.put("url", "data", "headers")
  end

  it "should delegate delete to the integration session" do
    @integration_session.should_receive(:delete).with("url", "data", "headers")
    rails_session = Webrat::RailsSession.new(@integration_session)
    rails_session.delete("url", "data", "headers")
  end

  context "the URL is a full path" do
    it "should pass the full url" do
      @integration_session.stub!(:https!)
      @integration_session.should_receive(:get).with("http://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is https://" do
    it "should call #https! with true before the request before passing along the full url" do
      @integration_session.should_receive(:https!).with(true)
      @integration_session.should_receive(:get).with("https://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("https://www.example.com/url", "data", "headers")
    end
  end

  context "the URL is http://" do
    it "should call #https! with true before the request" do
      @integration_session.stub!(:get)
      @integration_session.should_receive(:https!).with(false)
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("http://www.example.com/url", "data", "headers")
    end
  end

  context "the URL include an anchor" do
    it "should strip out the anchor" do
      @integration_session.should_receive(:https!).with(false)
      @integration_session.should_receive(:get).with("http://www.example.com/url", "data", "headers")
      rails_session = Webrat::RailsSession.new(@integration_session)
      rails_session.get("http://www.example.com/url#foo", "data", "headers")
    end
  end

  it "should provide a saved_page_dir" do
    Webrat::RailsSession.new(mock("integration session")).should respond_to(:saved_page_dir)
  end

  it "should provide a doc_root" do
    Webrat::RailsSession.new(mock("integration session")).should respond_to(:doc_root)
  end

  it "should accept an ActiveRecord argument to #within and translate to a selector using dom_id" do
    body = <<-HTML
      <a href="/page1">Edit</a>
      <div id="new_object">
        <a href="/page2">Edit</a>
      </div>
    HTML

    response = mock("response", :body => body, :headers => {}, :code => 200)
    @integration_session.stub!(:response => response)
    @integration_session.should_receive(:get).with("/page2", {}, nil)

    rails_session = Webrat::RailsSession.new(@integration_session)

    object = Object.new
    object.stub!(:id => nil)

    rails_session.within(object) do
      rails_session.click_link 'Edit'
    end
  end
end
