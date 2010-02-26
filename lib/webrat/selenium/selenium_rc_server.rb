module Webrat
  module Selenium

    class SeleniumRCServer

      include Webrat::Selenium::SilenceStream

      def self.boot
        new.boot
      end

      def boot
        return if selenium_grid?

        start
        wait
        stop_at_exit
      end

      def start
        silence_stream(STDOUT) do
          remote_control.start :background => true
        end
      end

      def stop_at_exit
        at_exit do
          stop
        end
      end

      def remote_control
        return @remote_control if @remote_control
        server_options = { :timeout => Webrat.configuration.selenium_browser_startup_timeout }
        server_options[:firefox_profile] = Webrat.configuration.selenium_firefox_profile if Webrat.configuration.selenium_firefox_profile

        @remote_control = ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0",
                                                                       Webrat.configuration.selenium_server_port,
                                                                       server_options)

        @remote_control.jar_file = jar_path

        return @remote_control
      end

      def jar_path
        File.expand_path(__FILE__ + "../../../../../vendor/selenium-server.jar")
      end

      def selenium_grid?
        Webrat.configuration.selenium_server_address
      end

      def wait
        $stderr.print "==> Waiting for Selenium RC server on port #{Webrat.configuration.selenium_server_port}... "
        wait_for_socket
        $stderr.print "Ready!\n"
      rescue SocketError
        fail
      end

      def wait_for_socket
        silence_stream(STDOUT) do
          TCPSocket.wait_for_service_with_timeout \
            :host     => (Webrat.configuration.selenium_server_address || "0.0.0.0"),
            :port     => Webrat.configuration.selenium_server_port,
            :timeout  => 45 # seconds
        end
      end

      def fail
        $stderr.puts
        $stderr.puts
        $stderr.puts "==> Failed to boot the Selenium RC server... exiting!"
        exit
      end

      def stop
        silence_stream(STDOUT) do
          ::Selenium::RemoteControl::RemoteControl.new("0.0.0.0",
                                                       Webrat.configuration.selenium_server_port,
                                                       :timeout => 5).stop
        end
      end

    end

  end
end
