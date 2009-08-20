module Merb #:nodoc:
  module Test #:nodoc:
    module RequestHelper #:nodoc:
      def request(uri, env = {})
        @_webrat_session ||= Webrat::MerbAdapter.new
        @_webrat_session.response = @_webrat_session.request(uri, env)
      end
    end
  end
end