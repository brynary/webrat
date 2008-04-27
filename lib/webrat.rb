Dir[File.join(File.dirname(__FILE__), "webrat", "*.rb")].each do |file|
  require File.expand_path(file)
end

module Webrat
  VERSION = '0.2.1'
end

module ActionController
  module Integration
    class Session
      
      unless instance_methods.include?("put_via_redirect")
        include Webrat::RedirectActions
      end

      def current_page
        @current_page ||= Webrat::Page.new(self)
      end
      
      def current_page=(new_page)
        @current_page = new_page
      end
      
      # Issues a GET request for a page, follows any redirects, and verifies the final page
      # load was successful.
      #
      # Example:
      #   visits "/"
      def visits(*args)
        @current_page = Webrat::Page.new(self, *args)
      end

      def save_and_open_page
        current_page.save_and_open
      end
      
      [:reloads, :fills_in, :clicks_button, :selects, :attaches_file, :chooses, :checks, :unchecks, :clicks_link, :clicks_link_within, :clicks_put_link, :clicks_get_link, :clicks_post_link, :clicks_delete_link].each do |method_name|
        define_method(method_name) do |*args|
          current_page.send(method_name, *args)
        end
      end
      
    end
  end
end

