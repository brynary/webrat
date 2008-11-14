require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Webrat::Core do
  
  before do
    Webrat::Core.cache_config_for_test
  end
  
  after do
    Webrat::Core.reset_for_test
  end
  
  it "should have a default config" do
    Webrat::Core.configuration.should be_an_instance_of(Webrat::Core)
  end
  
  it "should set default values" do
    config = Webrat::Core.configuration
    config.open_error_files.should == true
  end
  
  it "should be configurable with a block" do
    Webrat::Core.configure do |config|
      config.open_error_files = false
    end
    config = Webrat::Core.configuration
    config.open_error_files.should == false
  end
  
end