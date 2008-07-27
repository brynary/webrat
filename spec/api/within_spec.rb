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
  
  it "should submit forms within a scope" do
    @session.response_body = <<-EOS
      <form id="form1" action="/form1">
        <label>Email: <input type="text" name="email" />
        <input type="submit" value="Add" />
      </form>
      <form id="form2" action="/form2">
        <label>Email: <input type="text" name="email" />
        <input type="submit" value="Add" />
      </form>
    EOS
    
    @session.should_receive(:get).with("/form2", "email" => "test@example.com")
    @session.within "#form2" do |scope|
      scope.fill_in "Email", :with => "test@example.com"
      scope.clicks_button
    end
  end
  
  it "should not find buttons outside of the scope" do
    @session.response_body = <<-EOS
      <form action="/form1">
        <input type="submit" value="Add" />
      </form>
      <form id="form2" action="/form2">
      </form>
    EOS
    
    @session.within "#form2" do |scope|
      lambda {
        scope.clicks_button
      }.should raise_error
    end
  end
end
