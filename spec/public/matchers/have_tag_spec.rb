require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "have_tag" do
  include Webrat::Matchers
  include Webrat::HaveTagMatcher
  
  before(:each) do
    @body = <<-HTML
      <div id='main'>
        <div class='inner'>hello, world!</div>
        <h2>Welcome "Bryan"</h2>
        <h3>Welcome 'Bryan'</h3>
        <h4>Welcome 'Bryan"</h4>
        <ul>
          <li>First</li>
          <li>Second</li>
        </ul>
      </div>
    HTML
  end

  it "should be able to match a tag" do
    @body.should have_tag("div")
  end
  
  it "should not match the tag when it should not match" do
    @body.should_not have_tag("p")
  end
  
  it "should be able to specify the content of the tag" do
    @body.should have_tag("div", :content => "hello, world!")
  end
  
  it "should be able to specify the content of the tag with double quotes in it" do
    @body.should have_tag("h2", :content => 'Welcome "Bryan"')
  end
  
  it "should be able to specify the content of the tag with single quotes in it" do
    @body.should have_tag("h3", :content => "Welcome 'Bryan'")
  end
  
  it "should be able to specify the content of the tag with both kinds of quotes" do
    @body.should have_tag("h4", :content => "Welcome 'Bryan\"")
  end
  
  it "should be able to specify the number of occurences of the tag" do
    @body.should have_tag("li", :count => 2)
  end
  
  it "should not match if the count is wrong" do
    lambda {
      @body.should have_tag("li", :count => 3)
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end
  
  it "should be able to specify the attributes of the tag" do
    @body.should have_tag("div", :class => "inner")
  end
  
  it "should be able to loop over all the matched elements" do
    @body.should have_tag("div") do |node|
      node.first.name.should == "div"
    end
  end
  
  it "should not match of any of the matchers in the block fail" do
    lambda {
      @body.should have_tag("div") do |node|
        node.first.name.should == "p"
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end
  
  it "should be able to use #have_tag in the block" do
    @body.should have_tag("div", :id => "main") do |node|
      node.should have_tag("div", :class => "inner")
    end
  end
  
  it "should not match any parent tags in the block" do
    lambda {
      @body.should have_tag("div", :class => "inner") do |node|
        node.should have_tag("div", :id => "main")
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end
  
  it "should work with items that have multiple child nodes" do
    @body.should have_tag("ul") do |n|
      n.should have_tag("li", :content => "First")
      n.should have_tag("li", :content => "Second")
    end
  end
  
  describe "asserts for tags" do
    include Test::Unit::Assertions
    
    before(:each) do
      should_receive(:response_body).and_return @body
      require 'test/unit'
    end
    
    describe "assert_have_tag" do
      it "should pass when body contains the tag" do
        assert_have_tag("div")
      end
      
      it "should pass when finding with additional selectors" do
        assert_have_tag("div", :class => "inner")
      end
      
      
      it "should throw an exception when the body doesn't have matching tag" do
        lambda {
          assert_have_tag("p")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
      
      it "should throw an exception when the body doesn't have a tag matching the attributes" do
        lambda {
          assert_have_tag("div", :class => "nope")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
    end
    
    describe "assert_have_no_tag" do
      it "should pass when the body doesn't contan the tag" do
        assert_have_no_tag("p")
      end
      
      it "should pass when the body doesn't contain the tag due to additional selectors missing" do
        assert_have_no_tag("div", :class => "nope")
      end
      
      it "should throw an exception when the body does contain the tag" do
        lambda {
          assert_have_no_tag("div")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
      
      it "should throw an exception when the body contains the tag with additional selectors" do
        lambda {
          assert_have_no_tag("div", :class => "inner")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
    end
  end
end
