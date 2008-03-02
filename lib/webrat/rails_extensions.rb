module ActionController
  module Integration

    class Session
      # Waiting for http://dev.rubyonrails.org/ticket/10497 to be committed.
      def put_via_redirect(path, parameters = {}, headers = {})
        put path, parameters, headers
        follow_redirect! while redirect?
        status
      end

      # Waiting for http://dev.rubyonrails.org/ticket/10497 to be committed.
      def delete_via_redirect(path, parameters = {}, headers = {})
        delete path, parameters, headers
        follow_redirect! while redirect?
        status
      end

    end
    
  end
end
