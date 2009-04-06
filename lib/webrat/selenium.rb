require "webrat"
gem "selenium-client", ">=1.2.14"
require "selenium/client"
require "webrat/selenium/selenium_session"
require "webrat/selenium/matchers"
require "webrat/core_extensions/tcp_socket"

module Webrat
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
