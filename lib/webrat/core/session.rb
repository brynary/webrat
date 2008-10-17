require "forwardable"
require "ostruct"

module Webrat
  class Session
    extend Forwardable
    include Logging
    include Flunk
    
    attr_reader :current_url
    
    def initialize
      @http_method     = :get
      @data            = {}
      @default_headers = {}
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
    
    def current_dom
      current_scope.dom
    end
    
    # For backwards compatibility -- removing in 1.0
    def current_page
      page = OpenStruct.new
      page.url = @current_url
      page.http_method = @http_method
      page.data = @data
      page
    end
    
    def doc_root
      nil
    end
    
    def saved_page_dir
      File.expand_path(".")
    end
    
    def basic_auth(user, pass)
      @default_headers['HTTP_AUTHORIZATION'] = "Basic " + ["#{user}:#{pass}"].pack("m*")
    end

    def headers
      @default_headers.dup
    end

    def request_page(url, http_method, data)
      h = headers
      h['HTTP_REFERER'] = @current_url if @current_url

      debug_log "REQUESTING PAGE: #{http_method.to_s.upcase} #{url} with #{data.inspect} and HTTP headers #{h.inspect}"
      if h.empty?
        send "#{http_method}", url, data || {}
      else
        send "#{http_method}", url, data || {}, h
      end

      save_and_open_page if exception_caught?
      flunk("Page load was not successful (Code: #{response_code.inspect})") unless success_code?
      
      @scope        = nil
      @current_url  = url
      @http_method  = http_method
      @data         = data
    end
    
    def success_code?
      (200..299).include?(response_code)
    end
    
    def exception_caught?
      response_body =~ /Exception caught/
    end
    
    def current_scope
      @scope ||= Scope.new(self, response_body)
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
      
    
    # Works like clicks_link, but only looks for the link text within a given selector
    # 
    # Example:
    #   clicks_link_within "#user_12", "Vote"
    def clicks_link_within(selector, link_text)
      within(selector) do |scope|
        scope.clicks_link(link_text)
      end
    end

    alias_method :click_link_within, :clicks_link_within
    
    def within(selector)
      yield Scope.new(self, response_body, selector)
    end
    
    def visits(url = nil, http_method = :get, data = {})
      request_page(url, http_method, data)
    end
    
    alias_method :visit, :visits
    
    def open_in_browser(path) # :nodoc
      `open #{path}`
    end
    
    def rewrite_css_and_image_references(response_html) # :nodoc
      return response_html unless doc_root
      response_html.gsub(/"\/(stylesheets|images)/, doc_root + '/\1')
    end

    def_delegators :current_scope, :fill_in,            :fills_in
    def_delegators :current_scope, :check,              :checks
    def_delegators :current_scope, :uncheck,            :unchecks
    def_delegators :current_scope, :choose,             :chooses
    def_delegators :current_scope, :select,             :selects
    def_delegators :current_scope, :attach_file,        :attaches_file
    def_delegators :current_scope, :click_link,         :clicks_link
    def_delegators :current_scope, :click_get_link,     :clicks_get_link
    def_delegators :current_scope, :click_delete_link,  :clicks_delete_link
    def_delegators :current_scope, :click_post_link,    :clicks_post_link
    def_delegators :current_scope, :click_put_link,     :clicks_put_link
    def_delegators :current_scope, :click_button,       :clicks_button
    
  end
end