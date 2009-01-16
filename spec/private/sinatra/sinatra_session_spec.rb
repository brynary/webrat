require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Webrat::SinatraSession, "API" do
  before :each do
    Webrat.configuration.mode = :sinatra
    @sinatra_session = Webrat::SinatraSession.new
  end

  it "should delegate get to sinatras get" do
    @sinatra_session.should_receive(:orig_get).with("url", { :env => "headers" })
    @sinatra_session.get("url", {}, "headers")
  end

  it "should delegate post to sinatras post" do
    @sinatra_session.should_receive(:orig_post).with("url", { :env => "headers" })
    @sinatra_session.post("url", {}, "headers")
  end

  it "should delegate put to sinatras put" do
    @sinatra_session.should_receive(:orig_put).with("url", { :env => "headers" })
    @sinatra_session.put("url", {}, "headers")
  end

  it "should delegate delete to sinatras delete" do
    @sinatra_session.should_receive(:orig_delete).with("url", { :env => "headers" })
    @sinatra_session.delete("url", {}, "headers")
  end
end
