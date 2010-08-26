require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "contain" do
  include Webrat::Matchers

  before(:each) do
    with_html <<-HTML
      <html>
      <div id='main'>
        <div class='inner'>hello, world!</div>
        <div class='another'>hello ladies</div>
      </div>
      </html>
    HTML
  end

  describe "#matches?" do
    it "should call element#contains? when the argument is a string" do
      webrat_session.response_body.should contain("hello, world!")
    end

    it "should call element#matches? when the argument is a regular expression" do
      webrat_session.response_body.should contain(/hello, world/)
    end

    it "should treat newlines as spaces" do
      "<div>it takes\ndifferent strokes</div>".should contain("it takes different strokes")
    end

    it "should multiple spaces as a single space" do
      "<div>it takes  different strokes</div>".should contain("it takes different strokes")
    end
  end

  describe "asserts for contains," do
    require 'test/unit'
    include Test::Unit::Assertions

    describe "assert_contain" do
      it "should pass when containing the text" do
        assert_contain("hello, world")
      end

      it "should pass when containing the regexp" do
        assert_contain(/hello, world/)
      end

      it "should respect current dom" do
        within ".inner" do
          assert_contain("hello, world")
        end
      end

      it "should throw an exception when the body doesnt contain the text" do
        lambda {
          assert_contain("monkeys")
        }.should raise_error(AssertionFailedError)
      end

      it "should throw an exception when the body doesnt contain the regexp" do
        lambda {
          assert_contain(/monkeys/)
        }.should raise_error(AssertionFailedError)
      end
    end

    describe "assert_not_contain" do
      it "should pass when not containing the text" do
        assert_not_contain("monkeys")
      end

      it "should pass when not containing the regexp" do
        assert_not_contain(/monkeys/)
      end

      it "should respect current dom" do
        within ".another" do
          assert_not_contain("hello, world")
        end
      end

      it "should throw an exception when the body does contain the text" do
        lambda {
          assert_not_contain("hello, world")
        }.should raise_error(AssertionFailedError)
      end

      it "should throw an exception when the body does contain the regexp" do
        lambda {
          assert_not_contain(/hello, world/)
        }.should raise_error(AssertionFailedError)
      end
    end
  end

  describe "#failure_message" do
    it "should include the content string" do
      hc = Webrat::Matchers::HasContent.new("hello, world!")
      hc.matches?(webrat_session.response_body)

      hc.failure_message.should include("\"hello, world!\"")
    end

    it "should include the content regular expresson" do
      hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
      hc.matches?(webrat_session.response_body)

      hc.failure_message.should include("/hello,\\sworld!/")
    end

    it "should include the element's inner content" do
      hc = Webrat::Matchers::HasContent.new(/hello,\sworld!/)
      hc.matches?(webrat_session.response_body)

      hc.failure_message.should include("hello, world!")
    end
  end
end
