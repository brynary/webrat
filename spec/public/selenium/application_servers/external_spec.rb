require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

require "webrat/selenium/application_servers/base"
require "webrat/selenium/application_servers/external"

describe Webrat::Selenium::ApplicationServers::External do

  it "should just boot up with no exceptions" do
    Webrat::Selenium::ApplicationServers::External.new.boot
  end

end
