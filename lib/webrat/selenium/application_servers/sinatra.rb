require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class Sinatra < Webrat::Selenium::ApplicationServers::Base

        def start
          fork do
            File.open('rack.pid', 'w') { |fp| fp.write Process.pid }
            exec 'rackup', File.expand_path(Dir.pwd + '/config.ru'), '-p', Webrat.configuration.application_port.to_s
          end
        end

        def stop
          silence_stream(STDOUT) do
            pid = File.read(pid_file)
            system("kill -9 #{pid}")
            FileUtils.rm_f pid_file
          end
        end

        def fail
          $stderr.puts
          $stderr.puts
          $stderr.puts "==> Failed to boot the Sinatra application server... exiting!"
          exit
        end

        def pid_file
          prepare_pid_file(Dir.pwd, 'rack.pid')
        end

      end
    end
  end
end
