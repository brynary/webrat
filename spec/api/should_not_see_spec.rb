require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "should_not_see" do
  before do
    @session = Webrat::TestSession.new
  end
  
  it "should fail if the string is in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    lambda {
      @session.should_not_see "Link"
    }.should raise_error
  end
  
  it "should fail if the regexp is in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    lambda {
      @session.should_not_see /Li(n)[ck]/
    }.should raise_error
  end
  
  it "should fail if the string is in the HTML scope" do
    @session.response_body = <<-EOS
      <div id="first">
        <a href="/page2">Link</a>
      </div>
      <div id="second">
      </div>
    EOS
    
    lambda {
      @session.within "#first" do |scope|
        scope.should_not_see "Link"
      end
    }.should raise_error
  end
  
  it "should pass if the string is not in the HTML scope" do
    @session.response_body = <<-EOS
      <div id="first">
        <a href="/page2">Link</a>
      </div>
      <div id="second">
      </div>
    EOS
    
    @session.within "#second" do |scope|
      scope.should_not_see "Link"
    end
  end
  
  it "should pass if the string is not in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Link</a>
    EOS
    
    @session.should_not_see "Missing"
  end
  
  it "should pass if the regexp is not in the HTML" do
    @session.response_body = <<-EOS
      <a href="/page2">Different</a>
    EOS
    
    @session.should_not_see /Li(n)[ck]/
  end
end
