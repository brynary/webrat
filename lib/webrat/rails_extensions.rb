module ActionController
  module Integration

    class Session
      
      unless instance_methods.include?("put_via_redirect")
        # Waiting for http://dev.rubyonrails.org/ticket/10497 to be committed.
        def put_via_redirect(path, parameters = {}, headers = {})
          put path, parameters, headers
          follow_redirect! while redirect?
          status
        end
      end

      unless instance_methods.include?("delete_via_redirect")
        # Waiting for http://dev.rubyonrails.org/ticket/10497 to be committed.
        def delete_via_redirect(path, parameters = {}, headers = {})
          delete path, parameters, headers
          follow_redirect! while redirect?
          status
        end
      end

    end
    
  end
end
