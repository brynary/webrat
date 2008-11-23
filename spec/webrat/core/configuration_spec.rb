require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Configuration do
  predicate_matchers[:parse_with_nokogiri]  = :parse_with_nokogiri?
  predicate_matchers[:open_error_files]     = :open_error_files?
  
  before do
    Webrat.cache_config_for_test
  end
  
  after do
    Webrat.reset_for_test
  end

  it "should have a mode" do
    Webrat.configuration.should respond_to(:mode)
  end
  
  it "should use Nokogiri as the parser by default" do
    Webrat.stub!(:on_java? => false)
    config = Webrat::Configuration.new
    config.should parse_with_nokogiri
  end
  
  it "should not use Nokogiri as the parser when on JRuby" do
    Webrat.stub!(:on_java? => true)
    config = Webrat::Configuration.new
    config.should_not parse_with_nokogiri
  end
  
  it "should open error files by default" do
    config = Webrat::Configuration.new
    config.should open_error_files
  end
  
  it "should be configurable with a block" do
    Webrat.configure do |config|
      config.open_error_files = false
    end
    
    config = Webrat.configuration
    config.should_not open_error_files
  end
end