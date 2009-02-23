require "webrat"
gem "selenium-client", ">=1.2.9"
require "selenium/client"
require "webrat/selenium/selenium_session"
require "webrat/selenium/matchers"

module Webrat

  def self.with_selenium_server #:nodoc:
    start_selenium_server
    yield
    stop_selenium_server
  end

  def self.start_selenium_server #:nodoc:
    unless Webrat.configuration.selenium_server_address
      remote_control = ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0", Webrat.configuration.selenium_server_port, 5)
      remote_control.jar_file = File.expand_path(__FILE__ + "../../../../vendor/selenium-server.jar")
      remote_control.start :background => true
    end
    TCPSocket.wait_for_service :host => (Webrat.configuration.selenium_server_address || "0.0.0.0"), :port => Webrat.configuration.selenium_server_port
  end

  def self.stop_selenium_server #:nodoc:
    ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0", Webrat.configuration.selenium_server_port, 5).stop unless Webrat.configuration.selenium_server_address
  end

  def self.pid_file
    if File.exists?('config.ru')
      prepare_pid_file(Dir.pwd, 'rack.pid')
    else
      prepare_pid_file("#{RAILS_ROOT}/tmp/pids", "mongrel_selenium.pid")
    end
  end
  # Start the appserver for the underlying framework to test
  #
  # Sinatra: requires a config.ru in the root of your sinatra app to use this
  # Merb: Attempts to use bin/merb and falls back to the system merb
  # Rails: Calls mongrel_rails to startup the appserver
  def self.start_app_server
    case Webrat.configuration.application_framework
    when :sinatra
      fork do
        File.open('rack.pid', 'w') { |fp| fp.write Process.pid }
        exec 'rackup', File.expand_path(Dir.pwd + '/config.ru'), '-p', Webrat.configuration.application_port.to_s
      end
    when :merb
      cmd = 'merb'
      if File.exist?('bin/merb')
        cmd = 'bin/merb'
      end
      system("#{cmd} -d -p #{Webrat.configuration.application_port} -e #{Webrat.configuration.application_environment}")
    else # rails
      system("mongrel_rails start -d --chdir='#{RAILS_ROOT}' --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} --pid #{pid_file} &")
    end
    TCPSocket.wait_for_service :host => Webrat.configuration.application_address, :port => Webrat.configuration.application_port.to_i
  end

  # Stop the appserver for the underlying framework under test
  #
  # Sinatra: Reads and kills the pid from the pid file created on startup
  # Merb: Reads and kills the pid from the pid file created on startup
  # Rails: Calls mongrel_rails stop to kill the appserver
  def self.stop_app_server 
    case Webrat.configuration.application_framework
    when :sinatra
      pid = File.read('rack.pid')
      system("kill -9 #{pid}")
      FileUtils.rm_f 'rack.pid'
    when :merb
      pid = File.read("log/merb.#{Webrat.configuration.application_port}.pid")
      system("kill -9 #{pid}")
      FileUtils.rm_f "log/merb.#{Webrat.configuration.application_port}.pid"
    else # rails
      system "mongrel_rails stop -c #{RAILS_ROOT} --pid #{pid_file}"
    end
  end

  def self.prepare_pid_file(file_path, pid_file_name)
    FileUtils.mkdir_p File.expand_path(file_path)
    File.expand_path("#{file_path}/#{pid_file_name}")
  end

  # To use Webrat's Selenium support, you'll need the selenium-client gem installed.
  # Activate it with (for example, in your <tt>env.rb</tt>):
  #
  #   require "webrat"
  #
  #   Webrat.configure do |config|
  #     config.mode = :selenium
  #   end
  #
  # == Dropping down to the selenium-client API
  #
  # If you ever need to do something with Selenium not provided in the Webrat API,
  # you can always drop down to the selenium-client API using the <tt>selenium</tt> method.
  # For example:
  #
  #   When "I drag the photo to the left" do
  #     selenium.dragdrop("id=photo_123", "+350, 0")
  #   end
  #
  # == Choosing the underlying framework to test
  #
  # Webrat assumes you're using rails by default but it can also work with sinatra
  # and merb.  To take advantage of this you can use the configuration block to
  # set the application_framework variable.
  #   require "webrat"
  #
  #   Webrat.configure do |config|
  #     config.mode = :selenium
  #     config.application_port = 4567
  #     config.application_framework = :sinatra  # could also be :merb
  #   end
  #
  # == Auto-starting of the appserver and java server
  #
  # Webrat will automatically start the Selenium Java server process and an instance
  # of Mongrel when a test is run. The Mongrel will run in the "selenium" environment
  # instead of "test", so ensure you've got that defined, and will run on port
  # Webrat.configuration.application_port.
  #
  # == Waiting
  #
  # In order to make writing Selenium tests as easy as possible, Webrat will automatically
  # wait for the correct elements to exist on the page when trying to manipulate them
  # with methods like <tt>fill_in</tt>, etc. In general, this means you should be able to write
  # your Webrat::Selenium tests ignoring the concurrency issues that can plague in-browser
  # testing, so long as you're using the Webrat API.
  module Selenium
    module Methods
      def response
        webrat_session.response
      end

      def wait_for(*args, &block)
        webrat_session.wait_for(*args, &block)
      end

      def save_and_open_screengrab
        webrat_session.save_and_open_screengrab
      end
    end
  end
end
if defined?(ActionController::IntegrationTest)
  module ActionController #:nodoc:
    IntegrationTest.class_eval do
      include Webrat::Methods
      include Webrat::Selenium::Methods
      include Webrat::Selenium::Matchers
    end
  end
end
