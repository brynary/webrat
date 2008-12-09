module Webrat
  module Logging #:nodoc:
    
    def debug_log(message) # :nodoc:
      return unless logger
      logger.debug message
    end

    def logger # :nodoc:
      case Webrat.configuration.mode
      when Webrat::Configuration::RAILS_MODE
        defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : nil
      when Webrat::Configuration::MERB_MODE
        Merb.logger
      else
        nil
      end
    end
  
  end
end