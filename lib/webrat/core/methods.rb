module Webrat
  module Methods
    
    def self.delegate_to_session(*meths)
      meths.each do |meth|
        self.class_eval <<-RUBY
          def #{meth}(*args, &blk)
            with_session do |sess|
              sess.#{meth}(*args, &blk)
            end
          end
        RUBY
      end
    end

    def with_session
      @session ||= ::Webrat::Session.new
      yield @session
      @session.response
    end

    # all of these methods delegate to the @session, which should
    # be created transparently.
    delegate_to_session :visits, :within, :clicks_link_within,
                        :reload, :header, :http_accept, :basic_auth,
                        :save_and_open_page, :fill_in, :check, 
                        :uncheck, :choose, :select, :attach_file,
                        :click_area, :click_link, :click_button,
                        :field_labeled                        

    alias reloads reload
    alias visit visits
    
  end
end