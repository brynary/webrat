require "rubygems"
require "hpricot"
require "forwardable"
require "English"

module Webrat
  class Page
    extend Forwardable
    include Logging
    include Flunk
    
    attr_reader :session
    attr_reader :url
    
    def initialize(session, url = nil, method = :get, data = {})
      @session  = session
      @url      = url
      @method   = method
      @data     = data

      reset_scope
      load_page if @url
      
      session.current_page = self
    end
    
    def http_method
      @method
    end
    
    def data
      @data
    end

    def scope
      @scope ||= Scope.new(self, session.response_body)
    end    
    
  protected
    
    def load_page
      session.request_page(@url, @method, @data)
      reset_scope
    end
    
    def reset_scope
      @scope = nil
    end
    
  end
end