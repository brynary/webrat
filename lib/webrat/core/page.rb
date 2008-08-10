require "rubygems"
require "hpricot"
require "forwardable"
require "English"

module Webrat
  class Page
    extend Forwardable
    include Logging
    include Flunk
    
    attr_reader :url
    attr_reader :data
    attr_reader :http_method
    
    def initialize(session, url = nil, method = :get, data = {})
      @session      = session
      @url          = url
      @http_method  = method
      @data         = data
      
      session.request_page(@url, @http_method, @data) if @url
      
      @scope = nil
    end

    def scope
      @scope ||= Scope.new(@session, @session.response_body)
    end
    
  end
end