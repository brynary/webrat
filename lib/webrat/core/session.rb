require "forwardable"
require "ostruct"

require "webrat/core/mime"
require "webrat/core/save_and_open_page"

module Webrat
  # A page load or form submission returned an unsuccessful response code (500-599)
  class PageLoadError < WebratError
  end

  class InfiniteRedirectError < WebratError
  end

  def self.session_class
    if Webrat.configuration.mode == :selenium
      SeleniumSession
    else
      Session
    end
  end

  def self.adapter_class
    case Webrat.configuration.mode
    when :rails
      RailsAdapter
    when :merb
      MerbAdapter
    when :rack
      RackAdapter
    when :rack_test
      warn("The :rack_test mode is deprecated. Please use :rack instead")
      require "webrat/rack"
      RackAdapter
    when :sinatra
      warn("The :sinatra mode is deprecated. Please use :rack instead")
      SinatraAdapter
    when :mechanize
      MechanizeAdapter
    else
      raise WebratError.new(<<-STR)
Unknown Webrat mode: #{Webrat.configuration.mode.inspect}

Please ensure you have a Webrat configuration block that specifies a mode
in your test_helper.rb, spec_helper.rb, or env.rb (for Cucumber).

This configure block supercedes the need to require "webrat/<framework>".

For example:

  Webrat.configure do |config|
    config.mode = :rails
  end
      STR
    end
  end

  class Session
    extend Forwardable
    include Logging
    include SaveAndOpenPage

    attr_accessor :adapter

    attr_reader :current_url
    attr_reader :elements

    def_delegators :@adapter, :response, :response_code, :response_body,
      :response_body=, :response_code=,
      :get, :post, :put, :delete

    def initialize(adapter = nil)
      @adapter         = adapter
      @http_method     = :get
      @data            = {}
      @default_headers = {}
      @custom_headers  = {}
      reset
    end

    def current_dom #:nodoc:
      current_scope.dom
    end

    # For backwards compatibility -- removing in 1.0
    def current_page #:nodoc:
      warn "current_page is deprecated and will be going away in the next release. Use current_url instead."
      page = OpenStruct.new
      page.url = @current_url
      page.http_method = @http_method
      page.data = @data
      page
    end

    def doc_root #:nodoc:
      nil
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

      process_request(http_method, url, data, h)

      save_and_open_page if exception_caught? && Webrat.configuration.open_error_files?
      raise PageLoadError.new("Page load was not successful (Code: #{response_code.inspect}):\n#{formatted_error}") unless success_code?

      reset

      @current_url  = url
      @http_method  = http_method
      @data         = data

      if internal_redirect?
        check_for_infinite_redirects
        request_page(response_location, :get, {})
      end

      return response
    end

    def check_for_infinite_redirects
      if current_url == response_location
        @_identical_redirect_count ||= 0
        @_identical_redirect_count += 1
      end

      if infinite_redirect_limit_exceeded?
        raise InfiniteRedirectError.new("#{Webrat.configuration.infinite_redirect_limit} redirects to the same URL (#{current_url.inspect})")
      end
    end

    def infinite_redirect_limit_exceeded?
       Webrat.configuration.infinite_redirect_limit &&
       (@_identical_redirect_count || 0) > Webrat.configuration.infinite_redirect_limit
    end

    def success_code? #:nodoc:
      (200..499).include?(response_code)
    end

    def redirect? #:nodoc:
      (response_code / 100).to_i == 3
    end

    def internal_redirect?
      return false unless redirect?
      #should keep internal_redirects if the subdomain changes
      current_host_domain = current_host.split('.')[-2..-1].join('.') rescue current_host
      response_location_host_domain = response_location_host.split('.')[-2..-1].join('.') rescue response_location_host
      current_host_domain == response_location_host_domain
    end

    #easy helper to pull out where we were redirected to
    def redirected_to
      redirect? ? response_location : nil
    end

    def exception_caught? #:nodoc:
      response_body =~ /Exception caught/
    end

    def current_scope #:nodoc:
      scopes.last || page_scope
    end

    # Reloads the last page requested. Note that this will resubmit forms
    # and their data.
    def reload
      request_page(@current_url, @http_method, @data)
    end

    webrat_deprecate :reloads, :reload


    # Works like click_link, but only looks for the link text within a given selector
    #
    # Example:
    #   click_link_within "#user_12", "Vote"
    def click_link_within(selector, link_text)
      within(selector) do
        click_link(link_text)
      end
    end

    webrat_deprecate :clicks_link_within, :click_link_within

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

    webrat_deprecate :visits, :visit

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

    def dom
      page_scope.dom
    end

    def xml_content_type?
      false
    end

    def simulate
      return if Webrat.configuration.mode == :selenium
      yield
    end

    def automate
      return unless Webrat.configuration.mode == :selenium
      yield
    end

    def_delegators :current_scope, :fill_in,            :fills_in
    def_delegators :current_scope, :set_hidden_field
    def_delegators :current_scope, :submit_form
    def_delegators :current_scope, :check,              :checks
    def_delegators :current_scope, :uncheck,            :unchecks
    def_delegators :current_scope, :choose,             :chooses
    def_delegators :current_scope, :select,             :selects
    def_delegators :current_scope, :unselect,           :unselects
    def_delegators :current_scope, :select_datetime,    :selects_datetime
    def_delegators :current_scope, :select_date,        :selects_date
    def_delegators :current_scope, :select_time,        :selects_time
    def_delegators :current_scope, :attach_file,        :attaches_file
    def_delegators :current_scope, :click_area,         :clicks_area
    def_delegators :current_scope, :click_link,         :clicks_link
    def_delegators :current_scope, :click_button,       :clicks_button
    def_delegators :current_scope, :field_labeled
    def_delegators :current_scope, :field_by_xpath
    def_delegators :current_scope, :field_with_id
    def_delegators :current_scope, :select_option
    def_delegators :current_scope, :field_named

  private

    def process_request(http_method, url, data, headers)
      if headers.empty?
        send "#{http_method}", url, data || {}
      else
        send "#{http_method}", url, data || {}, headers
      end
    end

    def response_location
      response.headers["Location"]
    end

    def current_host
      URI.parse(current_url).host || @custom_headers["Host"] || "www.example.com"
    end

    def response_location_host
      URI.parse(response_location).host || "www.example.com"
    end

    def reset
      @elements     = {}
      @_scopes      = nil
      @_page_scope  = nil
    end

  end
end
