require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "webrat/selenium/silence_stream"
require "webrat/selenium/application_server_factory"
require "webrat/selenium/application_server"

require "webrat/selenium/sinatra_application_server"
require "webrat/selenium/merb_application_server"
require "webrat/selenium/rails_application_server"

describe Webrat::Selenium::ApplicationServerFactory do

  it "should require and create a sinatra server in sinatra mode" do
    server = mock(Webrat::Selenium::SinatraApplicationServer)
    Webrat.configuration.application_framework = :sinatra
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/sinatra_application_server")
    Webrat::Selenium::SinatraApplicationServer.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance.should == server
  end

  it "should require and create a merb server in merb mode" do
    server = mock(Webrat::Selenium::MerbApplicationServer)
    Webrat.configuration.application_framework = :merb
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/merb_application_server")
    Webrat::Selenium::MerbApplicationServer.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance
  end

  it "should require and create a rails server in rails mode" do
    server = mock(Webrat::Selenium::RailsApplicationServer)
    Webrat.configuration.application_framework = :rails
    Webrat::Selenium::ApplicationServerFactory.should_receive(:require).with("webrat/selenium/rails_application_server")
    Webrat::Selenium::RailsApplicationServer.should_receive(:new).and_return(server)
    Webrat::Selenium::ApplicationServerFactory.app_server_instance
  end

  it "should handle unknown servers with an exception in unknown modes" do
    Webrat.configuration.application_framework = :unknown
    lambda {
      Webrat::Selenium::ApplicationServerFactory.app_server_instance
    }.should raise_error(Webrat::WebratError)
  end

end
