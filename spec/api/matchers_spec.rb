require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Webrat::Matchers do
  include Webrat::Matchers
  
  before(:each) do
    @body = <<-EOF
    <div id='main'>
      <div class='inner'>hello, world!</div>
    </div>
    EOF
  end
  
  describe "#have_selector" do
    
    it "should be able to match a CSS selector" do
      @body.should have_selector("div")
    end
    
    it "should not match a CSS selector that does not exist" do
      @body.should_not have_selector("p")
    end
    
    it "should be able to loop over all the matched elements" do
      @body.should have_selector("div") { |node| node.name.should == "div" }
    end
    
    it "should not match of any of the matchers in the block fail" do
      lambda {
        @body.should_not have_selector("div") { |node| node.name.should == "p" }
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
    
  end
   
  describe Webrat::Matchers::HasContent do
    include Webrat::Matchers
    
    before(:each) do
      @element = stub(:element)
      @element.stub!(:inner_text).and_return <<-EOF
        <div id='main'>
          <div class='inner'>hello, world!</div>
        </div>
      EOF
      
      @element.stub!(:contains?)
      @element.stub!(:matches?)
    end
    
    describe "#matches?" do
      it "should call element#contains? when the argument is a string" do
        @element.should_receive(:contains?)
        
        Webrat::Matchers::HasContent.new("hello, world!").matches?(@element)
      end
      
      it "should call element#matches? when the argument is a regular expression" do
        @element.should_receive(:matches?)
        
        Webrat::Matchers::HasContent.new(/hello, world/).matches?(@element)
      end
    end
  
    describe "#failure_message" do
      it "should include the content string" do
        hc = Webrat::Matchers::HasContent.new("hello, world!")
        hc.matches?(@element)
        
        hc.failure_message.should include("\"hello, world!\"")
      end
      
      it "should include the content regular expresson" do
        hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
        hc.matches?(@element)
        
        hc.failure_message.should include("/hello,\\sworld!/")
      end
      
      it "should include the element's inner content" do
        hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
        hc.matches?(@element)
        
        hc.failure_message.should include(@element.inner_text)
      end
    end
  end
end
