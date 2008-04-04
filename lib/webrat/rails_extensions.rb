module Webrat
  module RedirectActions
    def put_via_redirect(path, parameters = {}, headers = {})
      put path, parameters, headers
      follow_redirect! while redirect?
      status
    end

    def delete_via_redirect(path, parameters = {}, headers = {})
      delete path, parameters, headers
      follow_redirect! while redirect?
      status
    end
  end
end

# Waiting for http://dev.rubyonrails.org/ticket/10497 to be committed.
  
module ActionController
  module Integration
    class Session
      include Webrat::RedirectActions unless instance_methods.include?("put_via_redirect")
    end
  end
end
