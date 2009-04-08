require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "have_tag" do
  include Webrat::Matchers
  include Webrat::HaveTagMatcher

  before(:each) do
    @body = <<-HTML
      <div id='main'>
        <div class='inner'>hello, world!</div>
      </div>
    HTML
  end

  it "should be an alias for have_selector" do
    @body.should have_tag("div")
  end

  describe "asserts for tags" do
    include Test::Unit::Assertions

    before(:each) do
      should_receive(:response_body).and_return @body
      require 'test/unit'
    end

    describe "assert_have_tag" do
      it "should be an alias for assert_have_selector" do
        assert_have_tag("div")
      end
    end

    describe "assert_have_no_tag" do
      it "should be an alias for assert_have_no_selector" do
        assert_have_no_tag("p")
      end
    end
  end
end
