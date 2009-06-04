module Webrat
  module Selenium
    module ApplicationServers
      class External < ApplicationServer
        def start
          warn "Webrat Ignoring Start Of Application Server Due to External Mode"
        end

        def stop
        end

        def fail
        end

        def pid_file
        end

        def wait
        end

      end
    end
  end
end