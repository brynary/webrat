require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Logging do
  include Webrat::Logging
  
  it "should log to RAILS_DEFAULT_LOGGER" do
    logger = mock("logger")
    RAILS_DEFAULT_LOGGER = logger
    logger.should_receive(:debug).with("Testing")
    debug_log "Testing"
  end
end