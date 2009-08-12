require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "have_xpath" do
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
          <li><a href="http://example.org">Third</a></li>
        </ul>
      </div>
    HTML
  end

  it "should be able to match an XPATH" do
    @body.should have_xpath("//div")
  end

  it "should be able to match an XPATH with attributes" do
    @body.should have_xpath("//div", :class => "inner")
  end

  it "should be able to match an XPATH with content" do
    @body.should have_xpath("//div", :content => "hello, world!")
  end

  it "should not match an XPATH without content" do
    @body.should_not have_xpath("//div", :content => "not present")
  end

  it "should be able to match an XPATH with content and class" do
    @body.should have_xpath("//div", :class => "inner", :content => "hello, world!")
  end

  it "should not match an XPATH with content and wrong class" do
    @body.should_not have_xpath("//div", :class => "outer", :content => "hello, world!")
  end

  it "should not match an XPATH with wrong content and class" do
    @body.should_not have_xpath("//div", :class => "inner", :content => "wrong")
  end

  it "should not match an XPATH with wrong content and wrong class" do
    @body.should_not have_xpath("//div", :class => "outer", :content => "wrong")
  end

  it "should not match a XPATH that does not exist" do
    @body.should_not have_xpath("//p")
  end

  it "should be able to loop over all the matched elements" do
    @body.should have_xpath("//div") do |node|
      node.first.name.should == "div"
    end
  end

  it "should not match if any of the matchers in the block fail" do
    lambda {
      @body.should have_xpath("//div") do |node|
        node.first.name.should == "p"
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end

  it "should be able to use #have_xpath in the block" do
    @body.should have_xpath("//div[@id='main']") do |node|
      node.should have_xpath("./div[@class='inner']")
    end
  end

  it "should convert absolute paths to relative in the block" do
    @body.should have_xpath("//div[@id='main']") do |node|
      node.should have_xpath("//div[@class='inner']")
    end
  end

  it "should not match any parent tags in the block" do
    lambda {
      @body.should have_xpath("//div[@class='inner']") do |node|
        node.should have_xpath("//div[@id='main']")
      end
    }.should raise_error(Spec::Expectations::ExpectationNotMetError)
  end

  it "should match descendants of the matched elements in the block" do
    @body.should have_xpath("//ul") do |node|
      node.should have_xpath("//a[@href='http://example.org']")
    end
  end

  it "should allow descendant selectors in the block" do
    @body.should have_xpath("//div[@id='main']") do |node|
      node.should have_xpath("//ul//a")
    end
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
        lambda {
          assert_have_xpath("//p")
        }.should raise_error(AssertionFailedError)
      end
    end

    describe "assert_have_no_xpath" do
      it "should pass when the body doesn't contan the xpath" do
        assert_have_no_xpath("//p")
      end

      it "should throw an exception when the body does contain the xpath" do
        lambda {
          assert_have_no_xpath("//div")
        }.should raise_error(AssertionFailedError)
      end
    end
  end
end
