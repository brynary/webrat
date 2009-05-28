module Webrat
  module Methods #:nodoc:

    def self.delegate_to_session(*meths)
      meths.each do |meth|
        self.class_eval <<-RUBY
          def #{meth}(*args, &blk)
            webrat_session.#{meth}(*args, &blk)
          end
        RUBY
      end
    end

    def webrat
      webrat_session
    end

    def webrat_session
      if Webrat.configuration.mode == :rack_test
        @_webrat_session ||= ::Webrat::RackTestSession.new(rack_test_session)
      else
        @_webrat_session ||= ::Webrat.session_class.new(self)
      end
    end

    # all of these methods delegate to the @session, which should
    # be created transparently.
    #
    # Note that when using Webrat, #request also uses @session, so
    # that #request and webrat native functions behave interchangably

    delegate_to_session \
      :visits, :visit,
      :within,
      :header, :http_accept, :basic_auth,
      :save_and_open_page,
      :fills_in, :fill_in,
      :checks, :check,
      :unchecks, :uncheck,
      :chooses, :choose,
      :selects, :select,
      :attaches_file, :attach_file,
      :current_page,
      :current_url,
      :clicks_link, :click_link,
      :clicks_area, :click_area,
      :clicks_button, :click_button,
      :reload, :reloads,
      :clicks_link_within, :click_link_within,
      :field_labeled,
      :select_option,
      :set_hidden_field, :submit_form,
      :request_page, :current_dom,
      :response_body,
      :selects_date, :selects_time, :selects_datetime,
      :select_date, :select_time, :select_datetime,
      :field_by_xpath,
      :field_with_id,
      :selenium,
      :simulate, :automate,
      :field_named
  end
end
