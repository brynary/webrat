module Webrat
  module Methods #:nodoc:

    def self.delegate_to_session(*meths)
      meths.each do |meth|
        self.class_eval(<<-RUBY, __FILE__, __LINE__)
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
      @_webrat_session ||= begin
        session = Webrat.session_class.new
        session.adapter = Webrat.adapter_class.new(self) if session.respond_to?(:adapter=)
        session
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
      :unselects, :unselect,
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
