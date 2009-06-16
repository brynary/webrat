require "webrat/selenium/silence_stream"

module Webrat
  module Selenium
    module ApplicationServers
      class Base
        include Webrat::Selenium::SilenceStream

        def boot
          start
          wait
          stop_at_exit
        end

        def stop_at_exit
          at_exit do
            stop
          end
        end

        def wait
          $stderr.print "==> Waiting for #{Webrat.configuration.application_framework} application server on port #{Webrat.configuration.application_port}... "
          wait_for_socket
          $stderr.print "Ready!\n"
        end

        def wait_for_socket
          silence_stream(STDOUT) do
            TCPSocket.wait_for_service_with_timeout \
              :host     => "0.0.0.0",
              :port     => Webrat.configuration.application_port.to_i,
              :timeout  => 30 # seconds
          end
          rescue SocketError
          fail
        end

        def prepare_pid_file(file_path, pid_file_name)
          FileUtils.mkdir_p File.expand_path(file_path)
          File.expand_path("#{file_path}/#{pid_file_name}")
        end

      end
    end
  end
end
