require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Logging do

  it "should always log outside of Rails and Merb" do
    FileUtils.rm("webrat.log")

    Webrat.configure do |config|
      config.mode = :rack
    end

    klass = Class.new
    klass.send(:include, Webrat::Logging)
    klass.new.debug_log "Testing"

    File.read("webrat.log").should match(/Testing/)
  end
end
