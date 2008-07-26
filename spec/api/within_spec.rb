require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "within" do
  before do
    @session = Webrat::TestSession.new
  end
  
  it "should click links within a scope" do
    @session.response_body = <<-EOS
    <a href="/page1">Link</a>
    <div id="container">
      <a href="/page2">Link</a>
    </div>
    EOS
    
    @session.should_receive(:get).with("/page2", {})
    @session.within "#container" do |scope|
      scope.clicks_link "Link"
    end
  end
end
