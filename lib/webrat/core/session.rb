require "forwardable"
require "ostruct"

require "webrat/core/mime"

module Webrat
  class PageLoadError < WebratError
  end
  
  class Session
    extend Forwardable
    include Logging
    
    attr_reader :current_url
    
    def initialize #:nodoc:
      @http_method     = :get
      @data            = {}
      @default_headers = {}
      @custom_headers  = {}
    end

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
    
    def current_dom #:nodoc:
      current_scope.dom
    end
    
    # For backwards compatibility -- removing in 1.0
    def current_page #:nodoc:
      page = OpenStruct.new
      page.url = @current_url
      page.http_method = @http_method
      page.data = @data
      page
    end
    
    def doc_root #:nodoc:
      nil
    end
    
    def saved_page_dir #:nodoc:
      File.expand_path(".")
    end

    def header(key, value)
      @custom_headers[key] = value
    end

    def http_accept(mime_type)
      header('Accept', Webrat::MIME.mime_type(mime_type))
    end
    
    def basic_auth(user, pass)
      encoded_login = ["#{user}:#{pass}"].pack("m*")
      header('HTTP_AUTHORIZATION', "Basic #{encoded_login}")
    end

    def headers #:nodoc:
      @default_headers.dup.merge(@custom_headers.dup)
    end

    def request_page(url, http_method, data) #:nodoc:
      h = headers
      h['HTTP_REFERER'] = @current_url if @current_url

      debug_log "REQUESTING PAGE: #{http_method.to_s.upcase} #{url} with #{data.inspect} and HTTP headers #{h.inspect}"
      if h.empty?
        send "#{http_method}", url, data || {}
      else
        send "#{http_method}", url, data || {}, h
      end

      save_and_open_page if exception_caught?
      raise PageLoadError.new("Page load was not successful (Code: #{response_code.inspect}):\n#{formatted_error}") unless success_code?
      
      @_scopes      = nil
      @_page_scope  = nil
      @current_url  = url
      @http_method  = http_method
      @data         = data
      
      return response
    end
    
    def success_code? #:nodoc:
      (200..499).include?(response_code)
    end
    
    def exception_caught? #:nodoc:
      response_body =~ /Exception caught/
    end
    
    def current_scope #:nodoc:
      scopes.last || page_scope
    end
    
    # Reloads the last page requested. Note that this will resubmit forms
    # and their data.
    #
    # Example:
    #   reloads
    def reloads
      request_page(@current_url, @http_method, @data)
    end

    alias_method :reload, :reloads
      
    
    # Works like click_link, but only looks for the link text within a given selector
    # 
    # Example:
    #   click_link_within "#user_12", "Vote"
    def click_link_within(selector, link_text)
      within(selector) do
        click_link(link_text)
      end
    end

    alias_method :clicks_link_within, :click_link_within
    
    def within(selector)
      scopes.push(Scope.from_scope(self, current_scope, selector))
      ret = yield(current_scope)
      scopes.pop
      return ret
    end
    
    # Issues a GET request for a page, follows any redirects, and verifies the final page
    # load was successful.
    #
    # Example:
    #   visit "/"
    def visit(url = nil, http_method = :get, data = {})
      request_page(url, http_method, data)
    end
    
    alias_method :visits, :visit
    
    def open_in_browser(path) #:nodoc
      `open #{path}`
    end
    
    def rewrite_css_and_image_references(response_html) #:nodoc
      return response_html unless doc_root
      response_html.gsub(/"\/(stylesheets|images)/, doc_root + '/\1')
    end

    # Subclasses can override this to show error messages without html
    def formatted_error #:nodoc:
      response_body
    end

    def scopes #:nodoc:
      @_scopes ||= []
    end

    def page_scope #:nodoc:
      @_page_scope ||= Scope.from_page(self, response, response_body)
    end
    
    def_delegators :current_scope, :fill_in,            :fills_in
    def_delegators :current_scope, :check,              :checks
    def_delegators :current_scope, :uncheck,            :unchecks
    def_delegators :current_scope, :choose,             :chooses
    def_delegators :current_scope, :select,             :selects
    def_delegators :current_scope, :attach_file,        :attaches_file
    def_delegators :current_scope, :click_area,         :clicks_area
    def_delegators :current_scope, :click_link,         :clicks_link
    def_delegators :current_scope, :click_button,       :clicks_button
    def_delegators :current_scope, :should_see
    def_delegators :current_scope, :should_not_see
    def_delegators :current_scope, :field_labeled
  end
end
