require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Logging do

  it "should not log if there is no logger" do
    klass = Class.new
    klass.send(:include, Webrat::Logging)
    klass.new.debug_log "Testing"
  end
end
