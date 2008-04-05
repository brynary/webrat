# For Rails before http://dev.rubyonrails.org/ticket/10497 was committed
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
