require "English"

require "webrat/core_extensions/blank"
require "webrat/core/elements/element"

module Webrat
  class Link < Element #:nodoc:

    def self.xpath_search
      [".//a[@href]"]
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

  protected

    def id
      @element["id"]
    end

    def data
      authenticity_token.blank? ? {} : {"authenticity_token" => authenticity_token}
    end

    def title
      @element["title"]
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
        ( onclick =~ /s\.setAttribute\('value', '([a-f0-9]{40})'\);/ || onclick =~ /s\.setAttribute\('value', '(.{44})'\);/ )
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
      elsif onclick.include?("m.setAttribute('value', 'post')")
        :post
      else
        raise Webrat::WebratError.new("No HTTP method for _method param in #{onclick.inspect}")
      end
    end

  end
end
