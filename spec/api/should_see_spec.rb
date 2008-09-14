require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "should_see" do
  before do
    @session = Webrat::TestSession.new
  end
  
  it "should pass if the string is in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    @session.should_see "Link"
  end
  
  it "should pass if the regexp is in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    @session.should_see /Li(n)[ck]/
  end
  
  it "should pass if the string is in the HTML scope" do
    @session.response_body = <<-EOS
      <div id="first">
        <a href="/page2">Link</a>
      </div>
      <div id="second">
      </div>
    EOS
    
    @session.within "#first" do |scope|
      scope.should_see "Link"
    end
  end
  
  it "should fail if the string is not in the HTML scope" do
    @session.response_body = <<-EOS
      <div id="first">
        <a href="/page2">Link</a>
      </div>
      <div id="second">
      </div>
    EOS
    
    lambda {
      @session.within "#second" do |scope|
        scope.should_see "Link"
      end
    }.should raise_error
  end
  
  it "should fail if the string is not in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    lambda {
      @session.should_see "Missing"
    }.should raise_error
  end
  
  it "should fail if the regexp is not in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Different</a>
    EOS
    
    lambda {
      @session.should_see /Li(n)[ck]/
    }.should raise_error
  end
end
