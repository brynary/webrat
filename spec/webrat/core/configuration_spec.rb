require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Core::Configuration do
  
  before do
    Webrat::Core::Configuration.cache_config_for_test
  end
  
  after do
    Webrat::Core::Configuration.reset_for_test
  end
  
  it "should have a default config" do
    Webrat::Core::Configuration.configuration.should be_an_instance_of(Webrat::Core::Configuration)
  end
  
  it "should set default values" do
    config = Webrat::Core::Configuration.configuration
    config.open_error_files.should == true
  end
  
  it "should be configurable with a block" do
    Webrat::Core::Configuration.configure do |config|
      config.open_error_files = false
    end
    config = Webrat::Core::Configuration.configuration
    config.open_error_files.should == false
  end
  
end