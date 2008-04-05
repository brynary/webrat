module Webrat
  class Link
    
    def initialize(link_element)
    end
    
    def click
    end
    
  protected
  
    def authenticity_token
      return unless onclick && onclick.include?("s.setAttribute('name', 'authenticity_token');") &&
        onclick =~ /s\.setAttribute\('value', '([a-f0-9]{40})'\);/
      $LAST_MATCH_INFO.captures.first
    end
    
    def onclick
    end
    
    def http_method
    end
    
    def http_method_from_js(onclick) 
      if !onclick.blank? && onclick.include?("f.submit()")
        http_method_from_js_form(onclick)
      else
        :get
      end
    end

    def http_method_from_js_form(onclick)
      if onclick.include?("m.setAttribute('name', '_method')")
        http_method_from_fake_method_param(onclick)
      else
        :post
      end
    end

    def http_method_from_fake_method_param(onclick)
      if onclick.include?("m.setAttribute('value', 'delete')")
        :delete
      elsif onclick.include?("m.setAttribute('value', 'put')")
        :put
      else
        raise "No HTTP method for _method param in #{onclick.inspect}"
      end
    end

  end
end