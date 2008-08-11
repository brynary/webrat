module Webrat
  module Logging
    
    def debug_log(message) # :nodoc:
      return unless logger
      logger.debug(message)
    end

    def logger # :nodoc:
      if defined? RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER
      else
        nil
      end
    end
  
  end
end