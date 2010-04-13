require "mechanize"

module Webrat #:nodoc:
  class MechanizeAdapter #:nodoc:
    extend Forwardable

    Mechanize = WWW::Mechanize if defined?(WWW::Mechanize)

    attr_accessor :response
    alias :page :response

    def initialize(*args)
    end

    def request_page(url, http_method, data) #:nodoc:
      super(absolute_url(url), http_method, data)
    end

    def get(url, data, headers_argument_not_used = nil)
      @response = mechanize.get(url, data)
    end

    def post(url, data, headers_argument_not_used = nil)
      post_data = data.inject({}) do |memo, param|
        case param
        when Hash
          param.each {|attribute, value| memo[attribute] = value }
          memo
        when Array
          case param.last
          when Hash
            param.last.each {|attribute, value| memo["#{param.first}[#{attribute}]"] = value }
          else
            memo[param.first] = param.last
          end
          memo
        end
      end
      @response = mechanize.post(url, post_data)
    end

    def response_body
      @response.content
    end

    def response_code
      @response.code.to_i
    end

    def response_headers
      @response.header
    end

    def mechanize
      @mechanize ||= begin
        mechanize = Mechanize.new
        mechanize.redirect_ok = false
        mechanize
      end
    end

    def_delegators :mechanize, :basic_auth

    def absolute_url(url) #:nodoc:
      current_host, current_path = split_current_url
      if url =~ Regexp.new('^https?://')
        url
      elsif url =~ Regexp.new('^/')
        current_host + url
      elsif url =~ Regexp.new('^\.')
        current_host + absolute_path(current_path, url)
      else
        url
      end
    end

    private
      def split_current_url
        current_url =~ Regexp.new('^(https?://[^/]+)(/.*)?')
        [Regexp.last_match(1), Regexp.last_match(2)]
      end

      def absolute_path(current_path, url)
        levels_up = url.split('/').find_all { |x| x == '..' }.size
        ancestor = if current_path.nil?
          ""
        else
          current_path.split("/")[0..(-1 - levels_up)].join("/")
        end
        descendent = url.split("/")[levels_up..-1].join
        "#{ancestor}/#{descendent}"
      end
  end
end
