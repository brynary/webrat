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
    
    describe 'asserts for xpath' do
      include Test::Unit::Assertions
       before(:each) do
          should_receive(:response_body).and_return @body
          require 'test/unit'
        end
        describe "assert_have_xpath" do
          it "should pass when body contains the selection" do
            assert_have_xpath("//div")
          end

          it "should throw an exception when the body doesnt have matching xpath" do
            lambda {assert_have_xpath("//p")}.should raise_error(Test::Unit::AssertionFailedError)
          end

        end

        describe "assert_have_no_xpath" do
          it "should pass when the body doesn't contan the xpath" do
            assert_have_no_xpath("//p")
          end

          it "should throw an exception when the body does contain the xpath" do
            lambda {assert_have_no_xpath("//div")}.should raise_error(Test::Unit::AssertionFailedError)
          end
        end
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
    
    describe "asserts for selector," do
      include Test::Unit::Assertions
      before(:each) do
        should_receive(:response_body).and_return @body
        require 'test/unit'
      end
      describe "assert_have_selector" do
        it "should pass when body contains the selection" do
          assert_have_selector("div")
        end
        
        it "should throw an exception when the body doesnt have matching selection" do
          lambda {assert_have_selector("p")}.should raise_error(Test::Unit::AssertionFailedError)
        end
        
      end
      
      describe "assert_have_not_selector" do
        it "should pass when the body doesn't contan the selection" do
          assert_have_no_selector("p")
        end
        
        it "should throw an exception when the body does contain the selection" do
          lambda {assert_have_no_selector("div")}.should raise_error(Test::Unit::AssertionFailedError)
        end
      end
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
    
    describe "asserts for tags," do
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
        
        
        it "should throw an exception when the body doesnt have matching tag" do
          lambda {assert_have_tag("p")}.should raise_error(Test::Unit::AssertionFailedError)
        end
        
        it "should throw an exception when the body doens't have a tag matching the additional selector" do
          lambda {assert_have_tag("div", :class => "nope")}.should raise_error(Test::Unit::AssertionFailedError)
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
          lambda {assert_have_no_tag("div")}.should raise_error(Test::Unit::AssertionFailedError)
        end
        
        it "should throw an exception when the body contains the tag with additional selectors" do
          lambda {assert_have_no_tag("div", :class => "inner")}.should raise_error(Test::Unit::AssertionFailedError)
        end
      end
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
    
    describe "asserts for contains," do
      include Test::Unit::Assertions
      before(:each) do
        should_receive(:response_body).and_return @body
        require 'test/unit'
      end
      describe "assert_contain" do
        it "should pass when containing the text" do
          assert_contain("hello, world")
        end
        
        it "should pass when containing the regexp" do
          assert_contain(/hello, world/)
        end
        
        it "should throw an exception when the body doesnt contain the text" do
          lambda {assert_contain("monkeys")}.should raise_error(Test::Unit::AssertionFailedError)
        end
        
        it "should throw an exception when the body doesnt contain the regexp" do
          lambda {assert_contain(/monkeys/)}.should raise_error(Test::Unit::AssertionFailedError)
        end
      end
      
      describe "assert_not_contain" do
        it "should pass when not containing the text" do
          assert_not_contain("monkeys")
        end
        
        it "should pass when not containing the regexp" do
          assert_not_contain(/monkeys/)
        end
        
        it "should throw an exception when the body does contain the text" do
          lambda {assert_not_contain("hello, world")}.should raise_error(Test::Unit::AssertionFailedError)
        end
        
        it "should throw an exception when the body does contain the regexp" do
          lambda {assert_not_contain(/hello, world/)}.should raise_error(Test::Unit::AssertionFailedError)
        end
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
