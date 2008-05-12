module Webrat
  class Session
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
    
    def method_missing(name, *args)
      if current_page.respond_to?(name)
        current_page.send(name, *args)
      else
        super
      end
    end
  end
end