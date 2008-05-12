module Webrat
  class Session
    
    def doc_root
      nil
    end
    
    def saved_page_dir
      File.expand_path(".")
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
    
    def respond_to?(name)
      super || current_page.respond_to?(name)
    end
    
    def save_and_open_page
      current_page.save_and_open
    end
    
    def method_missing(name, *args)
      if current_page.respond_to?(name)
        current_page.send(name, *args)
      else
        super
      end
    end
    
  end
end