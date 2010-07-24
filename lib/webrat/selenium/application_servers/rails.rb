require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class Rails < Webrat::Selenium::ApplicationServers::Base

        def start
          system start_command
        end

        def stop
          silence_stream(STDOUT) do
            system stop_command
          end
        end

        def fail
          $stderr.puts
          $stderr.puts
          $stderr.puts "==> Failed to boot the Rails application server... exiting!"
          $stderr.puts
          $stderr.puts "Verify you can start a Rails server on port #{Webrat.configuration.application_port} with the following command:"
          $stderr.puts
          $stderr.puts "    #{start_command}"
          exit
        end

        def pid_file
          prepare_pid_file("#{::Rails.root}/tmp/pids", "mongrel_selenium.pid")
        end

        def start_command
          "mongrel_rails start -d --chdir='#{::Rails.root}' --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} --pid #{pid_file} &"
        end

        def stop_command
          "mongrel_rails stop -c #{::Rails.root} --pid #{pid_file}"
        end

      end
    end
  end
end
