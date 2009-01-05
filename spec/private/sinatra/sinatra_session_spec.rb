require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Webrat::SinatraSession, "API" do
  before :each do
    Webrat.configuration.mode = :sinatra
    @sinatra_session = Webrat::SinatraSession.new
    @response = mock("response", :redirect? => false)
    @sinatra_session.stub!(:response => @response)
  end

  it "should delegate get to get_it" do
    @sinatra_session.should_receive(:get_it).with("url", { :env => "headers" })
    @sinatra_session.get("url", {}, "headers")
  end

  it "should delegate post to post_it" do
    @sinatra_session.should_receive(:post_it).with("url", { :env => "headers" })
    @sinatra_session.post("url", {}, "headers")
  end

  it "should delegate put to put_it" do
    @sinatra_session.should_receive(:put_it).with("url", { :env => "headers" })
    @sinatra_session.put("url", {}, "headers")
  end

  it "should delegate delete to delete_it" do
    @sinatra_session.should_receive(:delete_it).with("url", { :env => "headers" })
    @sinatra_session.delete("url", {}, "headers")
  end

  it "should use Session#request_page to handle redirects" do
    @response.should_receive(:redirect?).twice.and_return(true, false)
    @response.should_receive(:location).and_return("redirect url")

    @sinatra_session.should_receive(:get_it).with("original url", { :env => "headers" })
    @sinatra_session.should_receive(:request_page).with("redirect url", :get, {})

    @sinatra_session.get("original url", {}, "headers")
  end
end