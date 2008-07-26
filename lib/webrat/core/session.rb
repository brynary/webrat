module Webrat
  class Session
    
    def doc_root
      nil
    end
    
    def saved_page_dir
      File.expand_path(".")
    end
    
    def request_page(url, method, data)
      debug_log "REQUESTING PAGE: #{method.to_s.upcase} #{url} with #{data.inspect}"
      send "#{method}", url, data || {}
    end
    
    def success_code?
      (200..299).include?(response_code)
    end
    
    def exception_caught?
      response_body =~ /Exception caught/
    end
    
    def current_page
      @current_page ||= Page.new(self)
    end
    
    def current_page=(new_page)
      @current_page = new_page
    end
    
    def visits(*args)
      Page.new(self, *args)
    end
    
    alias_method :visit, :visits
    
    def respond_to?(name)
      super || current_page.respond_to?(name)
    end
    
    def save_and_open_page
      current_page.save_and_open
    end
    
    def method_missing(name, *args, &block)
      if current_page.respond_to?(name)
        current_page.send(name, *args, &block)
      else
        super
      end
    end
    
  end
end