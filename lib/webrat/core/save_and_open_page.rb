module Webrat
  module SaveAndOpenPage
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
    
    def open_in_browser(path) # :nodoc
      platform = ruby_platform
      if platform =~ /cygwin/ || platform =~ /win32/
        `rundll32 url.dll,FileProtocolHandler #{path.gsub("/", "\\\\")}`
      elsif platform =~ /darwin/
        `open #{path}`
      end
    end
    
    def rewrite_css_and_image_references(response_html) # :nodoc:
      return response_html unless doc_root
      response_html.gsub(/"\/(stylesheets|images)/, doc_root + '/\1')
    end
    
    def saved_page_dir #:nodoc:
      File.expand_path(".")
    end
    
    def doc_root #:nodoc:
      nil
    end
  
  private

    # accessor for testing
    def ruby_platform
      RUBY_PLATFORM
    end
    
  end
end