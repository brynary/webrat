require "webrat"
gem "selenium-client", ">=1.2.9"
require "selenium/client"
require "webrat/selenium/selenium_session"

Webrat.configuration.mode = :selenium

module Webrat
  
  def self.with_selenium_server #:nodoc:
    start_selenium_server
    yield
    stop_selenium_server
  end
  
  def self.start_selenium_server #:nodoc:
    remote_control = ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0", 4444, 5)
    remote_control.jar_file = File.expand_path(__FILE__ + "../../../../vendor/selenium-server.jar")
    remote_control.start :background => true
    TCPSocket.wait_for_service :host => "0.0.0.0", :port => 4444
  end
  
  def self.stop_selenium_server #:nodoc:
    remote_control = ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0", 4444, 5)
    remote_control.stop
  end
  
  def self.start_app_server #:nodoc:
    pid_file = File.expand_path(RAILS_ROOT + "/tmp/pids/mongrel_selenium.pid")
    system("mongrel_rails start -d --chdir=#{RAILS_ROOT} --port=3001 --environment=selenium --pid #{pid_file} &")
    TCPSocket.wait_for_service :host => "0.0.0.0", :port => 3001
  end
  
  def self.stop_app_server #:nodoc:
    pid_file = File.expand_path(RAILS_ROOT + "/tmp/pids/mongrel_selenium.pid")
    system "mongrel_rails stop -c #{RAILS_ROOT} --pid #{pid_file}"
  end
  
  module Selenium #:nodoc:
    module Rails #:nodoc:
      class World < ::ActionController::IntegrationTest
        
        def initialize #:nodoc:
          @_result = Test::Unit::TestResult.new
        end
        
      end
    end
  end
    
end

module ::ActionController #:nodoc:
  module Integration #:nodoc:
    class Session #:nodoc:
      include Webrat::Methods
    end
  end
end