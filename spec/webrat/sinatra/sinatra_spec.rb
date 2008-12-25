require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Webrat::SinatraSession do
  before :each do
    @sinatra_session = Webrat::SinatraSession.new

    @response = mock(:response)
    @response.stub!(:redirect?)

    @sinatra_session.instance_variable_set("@response", @response)
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
end

# Hack required to reset configuration mode to play nice with other specs that depend on this being rails
Webrat.configuration.mode = :rails