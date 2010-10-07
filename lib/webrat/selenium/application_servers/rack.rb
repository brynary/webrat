require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class Rack < Webrat::Selenium::ApplicationServers::Base

        def start
          @pid = fork do
            if File.exist?("log")
              redirect_io(STDOUT, File.join("log", "webrat.webrick.stdout.log"))
              redirect_io(STDERR, File.join("log", "webrat.webrick.stderr.log"))
            end
            exec start_command
          end
        end

        def stop
          Process.kill("INT", @pid)
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
          "#{bundler} rackup -s webrick --port #{Webrat.configuration.application_port} --env #{Webrat.configuration.application_environment}".strip
        end

      private

        def bundler
          File.exist?("./Gemfile") ? "bundle exec " : ""
        end

        def redirect_io(io, path)
          File.open(path, 'ab') { |fp| io.reopen(fp) } if path
          io.sync = true
        end

      end
    end
  end
end
