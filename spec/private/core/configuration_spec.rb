require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Configuration do
  
  Spec::Matchers.define :parse_with_nokogiri do
    match do |config|
      config.parse_with_nokogiri?
    end
  end
  
  Spec::Matchers.define :open_error_files do
    match do |config|
      config.open_error_files?
    end
  end
  
  it "should have a mode" do
    Webrat.configuration.should respond_to(:mode)
  end

  it "should use Nokogiri as the parser by default" do
    config = Webrat::Configuration.new
    config.should parse_with_nokogiri
  end

  it "should open error files by default" do
    config = Webrat::Configuration.new
    config.should open_error_files
  end

  it "should detect infinite redirects after 10" do
    config = Webrat::Configuration.new
    config.infinite_redirect_limit.should == 10
  end

  it "should be configurable with a block" do
    Webrat.configure do |config|
      config.open_error_files = false
    end

    config = Webrat.configuration
    config.should_not open_error_files
  end

  it "should be configurable with multiple blocks" do
    Webrat.configure do |config|
      config.open_error_files = false
    end

    Webrat.configure do |config|
      config.selenium_server_port = 1234
    end

    config = Webrat.configuration
    config.should_not open_error_files
    config.selenium_server_port.should == 1234
  end

  [:rails,
  :selenium,
  :rack,
  :sinatra,
  :mechanize].each do |mode|
    it "should require correct lib when in #{mode} mode" do
      config = Webrat::Configuration.new
      config.should_receive(:require).with("webrat/#{mode}")
      config.mode = mode
    end
  end

  it "should require merb_session when in merb mode" do
    config = Webrat::Configuration.new
    config.should_receive(:require).with("webrat/merb_session")
    config.mode = :merb
  end

  describe "Selenium" do
    before :each do
      @config = Webrat::Configuration.new
    end

    it "should use 'test' as the application environment by default" do
      @config.application_environment.should == :test
    end

    it "should use 3001 as the application port by default" do
      @config.application_port.should == 3001
    end

    it 'should default application address to localhost' do
      @config.application_address.should == 'localhost'
    end

    it 'should default selenium server address to nil' do
      @config.selenium_server_address.should be_nil
    end

    it 'should default selenium server port to 4444' do
      @config.selenium_server_port.should == 4444
    end

    it 'should default selenium browser key to *firefox' do
      @config.selenium_browser_key.should == '*firefox'
    end

    it 'should default selenium browser startup timeout to 5 seconds' do
      @config.selenium_browser_startup_timeout.should == 5
    end

    it 'should allow overriding of the browser startup timeout' do
      @config.selenium_browser_startup_timeout = 10
      @config.selenium_browser_startup_timeout.should == 10
    end
  end

end
