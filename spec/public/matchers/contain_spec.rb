require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "contain" do
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
        </ul>
      </div>
    HTML
  end

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
        lambda {
          assert_contain("monkeys")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end

      it "should throw an exception when the body doesnt contain the regexp" do
        lambda {
          assert_contain(/monkeys/)
        }.should raise_error(Test::Unit::AssertionFailedError)
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
        lambda {
          assert_not_contain("hello, world")
        }.should raise_error(Test::Unit::AssertionFailedError)
      end

      it "should throw an exception when the body does contain the regexp" do
        lambda {
          assert_not_contain(/hello, world/)
        }.should raise_error(Test::Unit::AssertionFailedError)
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
