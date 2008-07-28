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
    
    def_delegators :scope, :fill_in,            :fills_in
    def_delegators :scope, :check,              :checks
    def_delegators :scope, :uncheck,            :unchecks
    def_delegators :scope, :choose,             :chooses
    def_delegators :scope, :select,             :selects
    def_delegators :scope, :attach_file,        :attaches_file
    def_delegators :scope, :click_link,         :clicks_link
    def_delegators :scope, :click_get_link,     :clicks_get_link
    def_delegators :scope, :click_delete_link,  :clicks_delete_link
    def_delegators :scope, :click_post_link,    :clicks_post_link
    def_delegators :scope, :click_put_link,     :clicks_put_link
    def_delegators :scope, :click_button,       :clicks_button

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