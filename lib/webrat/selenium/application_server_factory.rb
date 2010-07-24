module Webrat
  module Selenium

    class ApplicationServerFactory

      def self.app_server_instance
        case Webrat.configuration.application_framework
        when :sinatra
          require "webrat/selenium/application_servers/sinatra"
          return Webrat::Selenium::ApplicationServers::Sinatra.new
        when :merb
          require "webrat/selenium/application_servers/merb"
          return Webrat::Selenium::ApplicationServers::Merb.new
        when :rails
          require "webrat/selenium/application_servers/rails"
          return Webrat::Selenium::ApplicationServers::Rails.new
        when :rack
          require "webrat/selenium/application_servers/rack"
          return Webrat::Selenium::ApplicationServers::Rack.new
        when :external
          require "webrat/selenium/application_servers/external"
          return Webrat::Selenium::ApplicationServers::External.new
        else
          raise WebratError.new(<<-STR)
Unknown Webrat application_framework: #{Webrat.configuration.application_framework.inspect}

Please ensure you have a Webrat configuration block that specifies an application_framework
in your test_helper.rb, spec_helper.rb, or env.rb (for Cucumber).

For example:

  Webrat.configure do |config|
    # ...
    config.application_framework = :rails
  end
      STR
        end
      end

    end

  end
end
