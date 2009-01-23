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

  def self.start_app_server #:nodoc:
    pid_file = prepare_pid_file("#{RAILS_ROOT}/tmp/pids", "mongrel_selenium.pid")
    system("mongrel_rails start -d --chdir=#{RAILS_ROOT} --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} --pid #{pid_file} &")
    TCPSocket.wait_for_service :host => Webrat.configuration.application_address, :port => Webrat.configuration.application_port.to_i
  end

  def self.stop_app_server #:nodoc:
    pid_file = File.expand_path(RAILS_ROOT + "/tmp/pids/mongrel_selenium.pid")
    system "mongrel_rails stop -c #{RAILS_ROOT} --pid #{pid_file}"
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
  # == Auto-starting of the mongrel and java server
  #
  # Webrat will automatically start the Selenium Java server process and an instance
  # of Mongrel when a test is run. The Mongrel will run in the "selenium" environment
  # instead of "test", so ensure you've got that defined, and will run on port 3001.
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

module ActionController #:nodoc:
  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Selenium::Methods
    include Webrat::Selenium::Matchers
  end
end
