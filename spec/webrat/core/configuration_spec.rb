require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Configuration do
  before do
    Webrat.cache_config_for_test
  end
  
  after do
    Webrat.reset_for_test
  end
  
  it "should have a default config" do
    Webrat.configuration.should be_an_instance_of(Webrat::Configuration)
  end
  
  it "should set default values" do
    config = Webrat.configuration
    config.open_error_files.should == true
  end
  
  it "should be configurable with a block" do
    Webrat.configure do |config|
      config.open_error_files = false
    end
    config = Webrat.configuration
    config.open_error_files.should == false
  end
end