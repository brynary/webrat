require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "action_controller"
require "action_controller/integration"
require "webrat/selenium"

describe Webrat::SeleniumSession do

  describe "create browser" do

    it "should start the local selenium client and set speed to 0 when selenium_server_address is nil" do
      selenium_session = Webrat::SeleniumSession.new
      browser = mock "mock browser"
      ::Selenium::Client::Driver.should_receive(:new).with("localhost", Webrat.configuration.selenium_server_port, "*firefox", "http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port}").and_return browser
      browser.should_receive(:set_speed).with(0)
      selenium_session.send :create_browser
    end

    it "should start the remote selenium client when selenium_server_address is set" do
      Webrat.configuration.selenium_server_address = 'foo address'
      selenium_session = Webrat::SeleniumSession.new
      browser = mock "mock browser"
      ::Selenium::Client::Driver.should_receive(:new).with(Webrat.configuration.selenium_server_address, Webrat.configuration.selenium_server_port, "*firefox", "http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port}").and_return browser
      browser.should_not_receive(:set_speed)
      selenium_session.send :create_browser
    end

    it "should use the config specifications" do
      Webrat.configuration.selenium_server_port = 'selenium port'
      Webrat.configuration.selenium_server_address = 'selenium address'
      Webrat.configuration.application_port = 'app port'
      Webrat.configuration.application_address = 'app address'
      Webrat.configuration.selenium_browser_key = 'browser key'

      selenium_session = Webrat::SeleniumSession.new
      browser = mock "mock browser"
      ::Selenium::Client::Driver.should_receive(:new).with('selenium address',
                      'selenium port', 'browser key',
                      "http://app address:app port").and_return browser
      browser.should_not_receive(:set_speed)
      selenium_session.send :create_browser
    end
  end

end