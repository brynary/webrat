require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class Rack < Webrat::Selenium::ApplicationServers::Base

        def start
          @pid = fork do
            exec start_command
          end
        end

        def stop
          Process.kill("TERM", @pid)
        end

        def fail
          $stderr.puts
          $stderr.puts
          $stderr.puts "==> Failed to boot the application server... exiting!"
          $stderr.puts
          $stderr.puts "Verify you can start a server on port #{Webrat.configuration.application_port} with the following command:"
          $stderr.puts
          $stderr.puts "    #{start_command}"
          exit
        end

        def start_command
          "rackup --port #{Webrat.configuration.application_port} --env #{Webrat.configuration.application_environment}"
        end

      end
    end
  end
end
