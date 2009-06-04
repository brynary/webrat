require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "webrat/selenium/silence_stream"
require "webrat/selenium/selenium_session"

describe Webrat::SeleniumSession do

  before :each do
    Webrat.configuration.mode = :selenium
    @selenium = Webrat::SeleniumSession.new()
  end

  it "should provide a list yieldable exceptions without spec if spec isn't defined" do
    @selenium.should_receive(:lib_defined?).with(::Spec::Expectations::ExpectationNotMetError).and_return(false)
    @selenium.yieldable_exceptions.should == [::Selenium::CommandError, Webrat::WebratError]
  end

  it "should provide a list yieldable exceptions with rspec" do
    @selenium.should_receive(:lib_defined?).with(::Spec::Expectations::ExpectationNotMetError).and_return(true)
    @selenium.yieldable_exceptions.should == [::Spec::Expectations::ExpectationNotMetError, ::Selenium::CommandError, Webrat::WebratError]
  end

  it "should throw timeout instead of spec expectionnotmet error" do
    lambda {
      @selenium.wait_for(:timeout => 0.1) do
        raise ::Spec::Expectations::ExpectationNotMetError
      end
    }.should raise_error(Webrat::TimeoutError)
  end

  it "should throw timeout instead of selenium command error" do
    lambda {
      @selenium.wait_for(:timeout => 0.1) do
        raise ::Selenium::CommandError
      end
    }.should raise_error(Webrat::TimeoutError)
  end

  it "should throw timeout instead of webrat error" do
    lambda {
      @selenium.wait_for(:timeout => 0.1) do
        raise Webrat::WebratError.new
      end
    }.should raise_error(Webrat::TimeoutError)
  end

end
