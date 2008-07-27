module Webrat
  class Session

    # Saves the page out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. Useful for debugging.
    # 
    # Example:
    #   save_and_open_page
    def save_and_open_page
      return unless File.exist?(saved_page_dir)

      filename = "#{saved_page_dir}/webrat-#{Time.now.to_i}.html"
      
      File.open(filename, "w") do |f|
        f.write rewrite_css_and_image_references(response_body)
      end

      open_in_browser(filename)
    end    
    
    def doc_root
      nil
    end
    
    def saved_page_dir
      File.expand_path(".")
    end
    
    def request_page(url, method, data)
      debug_log "REQUESTING PAGE: #{method.to_s.upcase} #{url} with #{data.inspect}"
      send "#{method}", url, data || {}
      
      save_and_open_page if exception_caught?
      flunk("Page load was not successful (Code: #{session.response_code.inspect})") unless success_code?
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
    
    def open_in_browser(path) # :nodoc
      `open #{path}`
    end
    
    def rewrite_css_and_image_references(response_html) # :nodoc
      return response_html unless doc_root
      response_html.gsub(/"\/(stylesheets|images)/, doc_root + '/\1')
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