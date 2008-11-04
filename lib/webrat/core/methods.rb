module Webrat
  module Methods
    
    def self.delegate_to_session(*meths)
      meths.each do |meth|
        self.class_eval <<-RUBY
          def #{meth}(*args, &blk)
            webrat_session.#{meth}(*args, &blk)
          end
        RUBY
      end
    end
    
    def self.delegate_to_session_returning_response(*meths)
      meths.each do |meth|
        self.class_eval <<-RUBY
          def #{meth}(*args, &blk)
            webrat_session.#{meth}(*args, &blk)
            return webrat_session.response
          end
        RUBY
      end
    end
    
    def webrat_session
      @webrat_session ||= ::Webrat::Session.new
    end

    delegate_to_session :within, :header, :http_accept, :basic_auth,
                        :save_and_open_page, :fill_in, :check, 
                        :uncheck, :choose, :select, :attach_file,
                        :field_labeled, :cookies, :response, :current_page,
                        :current_url

    delegate_to_session_returning_response :visits, :click_link, :click_area, :click_button, :reload, :clicks_link_within
    
    alias reloads reload
    alias visit visits
    
  end
end