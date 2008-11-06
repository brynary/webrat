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
    
    def webrat_session
      @webrat_session ||= ::Webrat::Session.new
    end

    delegate_to_session \
      :visits, :visit,
      :within,
      :header, :http_accept, :basic_auth,
      :save_and_open_page,
      :fill_in,
      :check, 
      :uncheck,
      :choose,
      :select,
      :attach_file,
      :cookies,
      :response,
      :current_page,
      :current_url,
      :click_link,
      :click_area,
      :click_button,
      :reload, :reloads,
      :clicks_link_within,
      :field_labeled
    
  end
end