require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "webrat/selenium/silence_stream"
require "webrat/selenium/application_server_factory"

require "webrat/selenium/application_servers"

describe Webrat::Selenium::ApplicationServerFactory do

  it "should require and create a sinatra server in sinatra mode" do
    server = mock(Webrat::Selenium::ApplicationServers::Sinatra)
    Webrat.configuration.application_framework = :sinatra
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/application_servers/sinatra")
    Webrat::Selenium::ApplicationServers::Sinatra.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance.should == server
  end

  it "should require and create a merb server in merb mode" do
    server = mock(Webrat::Selenium::ApplicationServers::Merb)
    Webrat.configuration.application_framework = :merb
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/application_servers/merb")
    Webrat::Selenium::ApplicationServers::Merb.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance
  end

  it "should require and create a rails server in rails mode" do
    server = mock(Webrat::Selenium::ApplicationServers::Rails)
    Webrat.configuration.application_framework = :rails
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/application_servers/rails")
    Webrat::Selenium::ApplicationServers::Rails.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance
  end

  it "should require and create a rails server in external mode" do
    server = mock(Webrat::Selenium::ApplicationServers::External)
    Webrat.configuration.application_framework = :external
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/application_servers/external")
    Webrat::Selenium::ApplicationServers::External.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance
  end

  it "should handle unknown servers with an exception in unknown modes" do
    Webrat.configuration.application_framework = :unknown
    lambda {
      Webrat::Selenium::ApplicationServerFactory.app_server_instance
    }.should raise_error(Webrat::WebratError)
  end

end
