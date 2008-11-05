require "webrat"

module Webrat
  class RailsSession < Session
    
    def initialize(integration_session)
      super()
      @integration_session = integration_session
    end

    def doc_root
      File.expand_path(File.join(RAILS_ROOT, 'public'))
    end
    
    def saved_page_dir
      File.expand_path(File.join(RAILS_ROOT, "tmp"))
    end
    
    def get(url, data, headers = nil)
      update_protocol(url)
      @integration_session.get_via_redirect(remove_protocol(url), data, headers)
    end
    
    def post(url, data, headers = nil)
      update_protocol(url)
      @integration_session.post_via_redirect(remove_protocol(url), data, headers)
    end
    
    def put(url, data, headers = nil)
      update_protocol(url)
      @integration_session.put_via_redirect(remove_protocol(url), data, headers)
    end
    
    def delete(url, data, headers = nil)
      update_protocol(url)
      @integration_session.delete_via_redirect(remove_protocol(url), data, headers)
    end
    
    def response_body
      response.body
    end
    
    def response_code
      response.code.to_i
    end
    
  protected
  
    def remove_protocol(href)
      if href =~ %r{^https?://www.example.com(/.*)}
        $LAST_MATCH_INFO.captures.first
      else
        href
      end
    end
    
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

module ActionController
  module Integration
    class Session
      
      unless instance_methods.include?("put_via_redirect")
        require "webrat/rails/redirect_actions"
        include Webrat::RedirectActions
      end

      def respond_to?(name)
        super || webrat_session.respond_to?(name)
      end
      
      def method_missing(name, *args, &block)
        if webrat_session.respond_to?(name)
          webrat_session.send(name, *args, &block)
        else
          super
        end
      end
      
    protected
    
      def webrat_session
        @webrat_session ||= Webrat::RailsSession.new(self)
      end
      
    end
  end
end