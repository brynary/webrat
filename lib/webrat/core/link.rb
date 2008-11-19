require "webrat/core_extensions/blank"

module Webrat
  class Link #:nodoc:
    
    def initialize(session, element)
      @session  = session
      @element  = element
    end
    
    def click(options = {})
      method = options[:method] || http_method
      return if href =~ /^#/ && method == :get
      
      options[:javascript] = true if options[:javascript].nil?
      
      if options[:javascript]
        @session.request_page(absolute_href, method, data)
      else
        @session.request_page(absolute_href, :get, {})
      end
    end
    
    def matches_text?(link_text)
      if link_text.is_a?(Regexp)
        matcher = link_text
      else
        matcher = /#{Regexp.escape(link_text.to_s)}/i
      end

      replace_nbsp(text) =~ matcher || replace_nbsp_ref(inner_html) =~ matcher || title =~ matcher
    end

    def matches_id?(id_or_regexp)
      if id_or_regexp.is_a?(Regexp)
        (id =~ id_or_regexp) ? true : false
      else
        (id == id_or_regexp) ? true : false
      end
    end

    def inner_html
      @element.inner_html
    end
    
    def text
      @element.inner_text
    end
    
  protected
    def id
      @element['id']
    end
  
    def data
      authenticity_token.blank? ? {} : {"authenticity_token" => authenticity_token}
    end

    def title
      @element['title']
    end

    def href
      @element["href"]
    end

    def absolute_href
      if href =~ /^\?/
        "#{@session.current_url}#{href}"
      elsif href !~ %r{^https?://} && (href !~ /^\//)
        "#{@session.current_url}/#{href}"
      else
        href
      end
    end
    
    def authenticity_token
      return unless onclick && onclick.include?("s.setAttribute('name', 'authenticity_token');") &&
        onclick =~ /s\.setAttribute\('value', '([a-f0-9]{40})'\);/
      $LAST_MATCH_INFO.captures.first
    end
    
    def onclick
      @element["onclick"]
    end
    
    def http_method
      if !onclick.blank? && onclick.include?("f.submit()")
        http_method_from_js_form
      else
        :get
      end
    end

    def http_method_from_js_form
      if onclick.include?("m.setAttribute('name', '_method')")
        http_method_from_fake_method_param
      else
        :post
      end
    end

    def http_method_from_fake_method_param
      if onclick.include?("m.setAttribute('value', 'delete')")
        :delete
      elsif onclick.include?("m.setAttribute('value', 'put')")
        :put
      else
        raise "No HTTP method for _method param in #{onclick.inspect}"
      end
    end

  private
    def replace_nbsp(str)
      str.gsub([0xA0].pack('U'), ' ')
    end

    def replace_nbsp_ref(str)
      str.gsub('&#xA0;',' ').gsub('&nbsp;', ' ')
    end
  end
end
