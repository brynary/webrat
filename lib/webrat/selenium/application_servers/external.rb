require "webrat/selenium/application_servers/base"

module Webrat
  module Selenium
    module ApplicationServers
      class External < Webrat::Selenium::ApplicationServers::Base
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
