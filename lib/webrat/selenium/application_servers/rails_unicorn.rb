require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class RailsUnicorn < Webrat::Selenium::ApplicationServers::Base

        def start
          system start_command
        end

        def stop
          silence_stream(STDOUT) do
            system stop_command
          end if File.exist?(pid_file)
        end

        def fail
          $stderr.puts
          $stderr.puts
          $stderr.puts "==> Failed to boot the Rails Unicorn application server... exiting!"
          $stderr.puts
          $stderr.puts "Verify you can start a Rails Unicorn server on port #{Webrat.configuration.application_port} with the following command:"
          $stderr.puts
          $stderr.puts "    #{start_command}"
          exit
        end

        def pid_file
          prepare_pid_file("#{::Rails.root}/tmp/pids", "unicorn.pid")
        end

        def start_command
          "cd '#{::Rails.root}' && #{bundler}#{unicorn} -D -p #{Webrat.configuration.application_port} -E #{Webrat.configuration.application_environment}#{unicorn_config}"
        end

        def stop_command
          "kill `cat '#{pid_file}'`"
        end

        private

        def bundler
          File.exist?("./Gemfile") ? "bundle exec " : ""
        end

        def unicorn
          if ::Rails.version && ::Rails.version[0,2] == "2."
            "unicorn_rails"
          else
            "unicorn"
          end
        end

        def unicorn_config
          conf_file = Webrat.configuration.unicorn_conf_file
          conf_file.blank? ? "" : " -c #{conf_file}"
        end

      end
    end
  end
end

