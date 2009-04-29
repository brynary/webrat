require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "have_selector" do
  include Webrat::Matchers

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
          <li><a href="http://example.org/">Third</a></li>
        </ul>
      </div>
    HTML
  end

  it "should be able to match a CSS selector" do
    @body.should have_selector("div")
  end

  it "should not match a CSS selector that does not exist" do
    @body.should_not have_selector("p")
  end

  describe "specifying attributes" do
    it "should be able to specify the attributes of the tag" do
      @body.should have_selector("div", :class => "inner")
    end
  end

  describe "specifying content" do
    it "should be able to specify the content of the tag" do
      @body.should have_selector("div", :content => "hello, world!")
    end

    it "should be able to specify the content of the tag with double quotes in it" do
      @body.should have_selector("h2", :content => 'Welcome "Bryan"')
    end

    it "should be able to specify the content of the tag with single quotes in it" do
      @body.should have_selector("h3", :content => "Welcome 'Bryan'")
    end

    it "should be able to specify the content of the tag with both kinds of quotes" do
      @body.should have_selector("h4", :content => "Welcome 'Bryan\"")
    end
  end

  describe "specifying counts" do
    it "should be able to specify the number of occurences of the tag" do
      @body.should have_selector("li", :count => 3)
    end

    it "should not match if the count is wrong" do
      lambda {
        @body.should have_selector("li", :count => 4)
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end
  end

  describe "specifying nested elements" do
    it "should be able to loop over all the matched elements" do
      @body.should have_selector("div") do |node|
        node.first.name.should == "div"
      end
    end

    it "should not match of any of the matchers in the block fail" do
      lambda {
        @body.should have_selector("div") do |node|
          node.first.name.should == "p"
        end
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    it "should be able to use #have_selector in the block" do
      @body.should have_selector("#main") do |node|
        node.should have_selector(".inner")
      end
    end

    it "should not match any parent tags in the block" do
      lambda {
        @body.should have_selector(".inner") do |node|
          node.should have_selector("#main")
        end
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    it "should work with items that have multiple child nodes" do
      @body.should have_selector("ul") do |n|
        n.should have_selector("li", :content => "First")
        n.should have_selector("li", :content => "Second")
      end
    end

    it "should work with descendants of the matched elements" do
      @body.should have_selector("ul") do |n|
        n.should have_selector("a", :content => "Third")
      end
    end
  end

  describe "Test::Unit assertions" do
    include Test::Unit::Assertions

    before(:each) do
      require 'test/unit'
      should_receive(:response_body).and_return @body
    end

    describe "assert_have_selector" do
      it "should pass when body contains the selection" do
        assert_have_selector("div")
      end

      it "should throw an exception when the body doesnt have matching selection" do
        lambda {
          assert_have_selector("p")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
    end

    describe "assert_have_not_selector" do
      it "should pass when the body doesn't contan the selection" do
        assert_have_no_selector("p")
      end

      it "should throw an exception when the body does contain the selection" do
        lambda {
          assert_have_no_selector("div")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end
    end
  end

end
