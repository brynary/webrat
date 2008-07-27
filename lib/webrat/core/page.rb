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
    
    # Reloads the last page requested. Note that this will resubmit forms
    # and their data.
    #
    # Example:
    #   reloads
    def reloads
      load_page
    end

    alias_method :reload, :reloads
    
    # Works like clicks_link, but only looks for the link text within a given selector
    # 
    # Example:
    #   clicks_link_within "#user_12", "Vote"
    def clicks_link_within(selector, link_text)
      session.within(selector) do |scope|
        scope.clicks_link(link_text)
      end
    end

    alias_method :click_link_within, :clicks_link_within
    
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
    
  protected
    
    def load_page
      session.request_page(@url, @method, @data)
      reset_scope
    end
    
    def reset_scope
      @scope = nil
    end
    
    def scope
      @scope ||= Scope.new(self, session.response_body)
    end
    
  end
end