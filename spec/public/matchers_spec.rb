require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Webrat::Matchers do
  include Webrat::Matchers
  include Webrat::HaveTagMatcher
  
  before(:each) do
    @body = <<-HTML
      <div id='main'>
        <div class='inner'>hello, world!</div>
        <ul>
          <li>First</li>
          <li>Second</li>
        </ul>
      </div>
    HTML
  end
  
  describe "#have_xpath" do
    it "should work with non-HTML documents" do
      xml = '<foo bar="baz"></foo>'
      xml.should have_xpath('/foo[@bar="baz"]')
    end
    
    it "should be able to match an XPATH" do
      @body.should have_xpath("//div")
    end
    
    it "should not match a XPATH that does not exist" do
      @body.should_not have_xpath("//p")
    end
    
    it "should be able to loop over all the matched elements" do
      @body.should have_xpath("//div") { |node| node.first.name.should == "div" }
    end
    
    it "should not match of any of the matchers in the block fail" do
      lambda {
        @body.should have_xpath("//div") { |node| node.first.name.should == "p" }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
    it "should be able to use #have_xpath in the block" do
      @body.should have_xpath("//div[@id='main']") { |node| node.should have_xpath("./div[@class='inner']") }
    end
    
    it "should convert absolute paths to relative in the block" do
      @body.should have_xpath("//div[@id='main']") { |node| node.should have_xpath("//div[@class='inner']") }
    end
    
    it "should not match any parent tags in the block" do
      lambda {
        @body.should have_xpath("//div[@class='inner']") { |node| node.should have_xpath("//div[@id='main']") }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
  end
  
  describe "#have_selector" do
    
    it "should be able to match a CSS selector" do
      @body.should have_selector("div")
    end
    
    it "should not match a CSS selector that does not exist" do
      @body.should_not have_selector("p")
    end
    
    it "should be able to loop over all the matched elements" do
      @body.should have_selector("div") { |node| node.first.name.should == "div" }
    end
    
    it "should not match of any of the matchers in the block fail" do
      lambda {
        @body.should have_selector("div") { |node| node.first.name.should == "p" }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
    it "should be able to use #have_selector in the block" do
      @body.should have_selector("#main") { |node| node.should have_selector(".inner") }
    end
    
    it "should not match any parent tags in the block" do
      lambda {
        @body.should have_selector(".inner") { |node| node.should have_selector("#main") }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
  end
  
  describe "#have_tag" do
    
    it "should be able to match a tag" do
      @body.should have_tag("div")
    end
    
    it "should not match the tag when it should not match" do
      @body.should_not have_tag("p")
    end
    
    it "should be able to specify the content of the tag" do
      @body.should have_tag("div", :content  => "hello, world!")
    end
    
    it "should be able to specify the attributes of the tag" do
      @body.should have_tag("div", :class => "inner")
    end
    
    it "should be able to loop over all the matched elements" do
      @body.should have_tag("div") { |node| node.first.name.should == "div" }
    end
    
    it "should not match of any of the matchers in the block fail" do
      lambda {
        @body.should have_tag("div") { |node| node.first.name.should == "p" }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
    it "should be able to use #have_tag in the block" do
      @body.should have_tag("div", :id => "main") { |node| node.should have_tag("div", :class => "inner") }
    end
    
    it "should not match any parent tags in the block" do
      lambda {
        @body.should have_tag("div", :class => "inner") { |node| node.should have_tag("div", :id => "main") }
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
    
    it "should work with items that have multiple child nodes" do
      @body.should have_tag("ul") { |n|
        n.should have_tag("li", :content => "First")
        n.should have_tag("li", :content => "Second")
      }
    end
    
  end

  describe Webrat::Matchers::HasContent do
    include Webrat::Matchers

    before(:each) do
      @body = <<-EOF
        <div id='main'>
          <div class='inner'>hello, world!</div>
        </div>
      EOF
    end
    
    describe "#matches?" do
      it "should call element#contains? when the argument is a string" do
        @body.should contain("hello, world!")
      end
      
      it "should call element#matches? when the argument is a regular expression" do
        @body.should contain(/hello, world/)
      end
    end
  
    describe "#failure_message" do
      it "should include the content string" do
        hc = Webrat::Matchers::HasContent.new("hello, world!")
        hc.matches?(@body)
        
        hc.failure_message.should include("\"hello, world!\"")
      end
      
      it "should include the content regular expresson" do
        hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
        hc.matches?(@body)
        
        hc.failure_message.should include("/hello,\\sworld!/")
      end
      
      it "should include the element's inner content" do
        hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
        hc.matches?(@body)
        
        hc.failure_message.should include("hello, world!")
      end
    end
  end
end
