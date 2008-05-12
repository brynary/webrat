module Webrat
  class RailsSession < Session
    
    def initialize(integration_session)
      @integration_session = integration_session
    end

    def doc_root
      File.expand_path(File.join(RAILS_ROOT, 'public'))
    end
    
    def saved_page_dir
      File.expand_path(File.join(RAILS_ROOT, "tmp"))
    end
    
    def get(url, data)
      @integration_session.get_via_redirect(url, data)
    end
    
    def post(url, data)
      @integration_session.post_via_redirect(url, data)
    end
    
    def put(url, data)
      @integration_session.put_via_redirect(url, data)
    end
    
    def delete(url, data)
      @integration_session.delete_via_redirect(url, data)
    end
    
    def response_body
      response.body
    end
    
    def response_code
      response.code.to_i
    end
    
  protected
  
    def update_protocol(href)
      if href =~ /^https:/
        @integration_session.https!(true)
      elsif href =~ /^http:/
        @integration_session.https!(false)
      end
    end
    
    def response
      @integration_session.response
    end
    
  end
end