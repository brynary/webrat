gem "selenium-client", ">=1.2.9"
require "selenium/client"
require "webrat/selenium/selenium_session"

Webrat.configuration.mode = :selenium

module Webrat
  
  def self.with_selenium_server
    start_selenium_server
    yield
    stop_selenium_server
  end
  
  def self.start_selenium_server
    remote_control = Selenium::RemoteControl::RemoteControl.new("0.0.0.0", 4444, 5)
    remote_control.jar_file = File.expand_path(__FILE__ + "../../../../vendor/selenium-server.jar")
    remote_control.start :background => true
    puts "Waiting for Remote Control to be up and running..."
    TCPSocket.wait_for_service :host => "0.0.0.0", :port => 4444
    puts "Selenium Remote Control at 0.0.0.0:4444 ready"
  end
  
  def self.stop_selenium_server
    puts "Stopping Selenium Remote Control running at 0.0.0.0:4444..."
    remote_control = Selenium::RemoteControl::RemoteControl.new("0.0.0.0", 4444, 5)
    remote_control.stop
    puts "Stopped Selenium Remote Control running at 0.0.0.0:4444"
  end
  
end