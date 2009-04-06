module Webrat
  module Selenium
    
    class MerbApplicationServer < ApplicationServer
      
      def start
        system start_command
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
        $stderr.puts "==> Failed to boot the Merb application server... exiting!"
        $stderr.puts
        $stderr.puts "Verify you can start a Merb server on port #{Webrat.configuration.application_port} with the following command:"
        $stderr.puts
        $stderr.puts "    #{start_command}"
        exit
      end
      
      def pid_file
        "log/merb.#{Webrat.configuration.application_port}.pid"
      end
      
      def start_command
        "#{merb_command} -d -p #{Webrat.configuration.application_port} -e #{Webrat.configuration.application_environment}"
      end

      def merb_command
        if File.exist?('bin/merb')
          merb_cmd = 'bin/merb'
        else
          merb_cmd = 'merb'
        end
      end
      
    end
    
  end
end