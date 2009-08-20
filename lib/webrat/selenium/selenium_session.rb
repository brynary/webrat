require "webrat/core/save_and_open_page"
require "webrat/selenium/selenium_rc_server"
require "webrat/selenium/application_server_factory"
require "webrat/selenium/application_servers/base"

require "selenium"

module Webrat
  class TimeoutError < WebratError
  end

  class SeleniumResponse
    attr_reader :body
    attr_reader :session

    def initialize(session, body)
      @session = session
      @body = body
    end

    def selenium
      session.selenium
    end
  end

  class SeleniumSession
    include Webrat::SaveAndOpenPage
    include Webrat::Selenium::SilenceStream

    def initialize(*args) # :nodoc:
    end

    def simulate
    end

    def automate
      yield
    end

    def visit(url)
      selenium.open(url)
    end

    webrat_deprecate :visits, :visit

    def fill_in(field_identifier, options)
      locator = "webrat=#{field_identifier}"
      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.type(locator, "#{options[:with]}")
    end

    webrat_deprecate :fills_in, :fill_in

    def response
      SeleniumResponse.new(self, response_body)
    end

    def response_body #:nodoc:
      selenium.get_html_source
    end

    def current_url
      selenium.location
    end

    def click_button(button_text_or_regexp = nil, options = {})
      if button_text_or_regexp.is_a?(Hash) && options == {}
        pattern, options = nil, button_text_or_regexp
      elsif button_text_or_regexp
        pattern = adjust_if_regexp(button_text_or_regexp)
      end
      pattern ||= '*'
      locator = "button=#{pattern}"

      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.click locator
    end

    webrat_deprecate :clicks_button, :click_button

    def click_link(link_text_or_regexp, options = {})
      pattern = adjust_if_regexp(link_text_or_regexp)
      locator = "webratlink=#{pattern}"
      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.click locator
    end

    webrat_deprecate :clicks_link, :click_link

    def click_link_within(selector, link_text, options = {})
      locator = "webratlinkwithin=#{selector}|#{link_text}"
      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.click locator
    end

    webrat_deprecate :clicks_link_within, :click_link_within

    def select(option_text, options = {})
      id_or_name_or_label = options[:from]

      if id_or_name_or_label
        select_locator = "webrat=#{id_or_name_or_label}"
      else
        select_locator = "webratselectwithoption=#{option_text}"
      end

      selenium.wait_for_element select_locator, :timeout_in_seconds => 5
      selenium.select(select_locator, option_text)
    end

    webrat_deprecate :selects, :select

    def choose(label_text)
      locator = "webrat=#{label_text}"
      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.click locator
    end

    webrat_deprecate :chooses, :choose

    def check(label_text)
      locator = "webrat=#{label_text}"
      selenium.wait_for_element locator, :timeout_in_seconds => 5
      selenium.click locator
    end
    alias_method :uncheck, :check

    webrat_deprecate :checks, :check

    def fire_event(field_identifier, event)
      locator = "webrat=#{Regexp.escape(field_identifier)}"
      selenium.fire_event(locator, "#{event}")
    end

    def key_down(field_identifier, key_code)
      locator = "webrat=#{Regexp.escape(field_identifier)}"
      selenium.key_down(locator, key_code)
    end

    def key_up(field_identifier, key_code)
      locator = "webrat=#{Regexp.escape(field_identifier)}"
      selenium.key_up(locator, key_code)
    end

    def wait_for(params={})
      timeout = params[:timeout] || 5
      message = params[:message] || "Timeout exceeded"

      begin_time = Time.now

      while (Time.now - begin_time) < timeout
        value = nil

        begin
          value = yield
        rescue Exception => e
          unless is_ignorable_wait_for_exception?(e)
            raise e
          end
        end

        return value if value

        sleep 0.25
      end

      raise Webrat::TimeoutError.new(message + " (after #{timeout} sec)")
      true
    end

    def selenium
      return $browser if $browser
      setup
      $browser
    end

    webrat_deprecate :browser, :selenium


    def save_and_open_screengrab
      return unless File.exist?(saved_page_dir)

      filename = "#{saved_page_dir}/webrat-#{Time.now.to_i}.png"

      if $browser.chrome_backend?
        $browser.capture_entire_page_screenshot(filename, '')
      else
        $browser.capture_screenshot(filename)
      end
      open_in_browser(filename)

    end

    protected
    def is_ignorable_wait_for_exception?(exception) #:nodoc:
      if defined?(::Spec::Expectations::ExpectationNotMetError)
        return true if exception.class == ::Spec::Expectations::ExpectationNotMetError
      end
      return true if [::Selenium::CommandError, Webrat::WebratError].include?(exception.class)
      return false
    end

    def setup #:nodoc:
      Webrat::Selenium::SeleniumRCServer.boot
      Webrat::Selenium::ApplicationServerFactory.app_server_instance.boot

      create_browser
      $browser.start

      extend_selenium
      define_location_strategies
      $browser.window_maximize
    end


    def create_browser
      $browser = ::Selenium::Client::Driver.new(Webrat.configuration.selenium_server_address || "localhost",
      Webrat.configuration.selenium_server_port, Webrat.configuration.selenium_browser_key, "http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port}")
      $browser.set_speed(0) unless Webrat.configuration.selenium_server_address

      at_exit do
        silence_stream(STDOUT) do
          $browser.stop
        end
      end
    end

    def adjust_if_regexp(text_or_regexp) #:nodoc:
      if text_or_regexp.is_a?(Regexp)
        "evalregex:#{text_or_regexp.inspect}"
      else
        "evalregex:/#{text_or_regexp}/"
      end
    end

    def extend_selenium #:nodoc:
      extensions_file = File.join(File.dirname(__FILE__), "selenium_extensions.js")
      extenions_js = File.read(extensions_file)
      selenium.get_eval(extenions_js)
    end

    def define_location_strategies #:nodoc:
      Dir[File.join(File.dirname(__FILE__), "location_strategy_javascript", "*.js")].sort.each do |file|
        strategy_js = File.read(file)
        strategy_name = File.basename(file, '.js')
        selenium.add_location_strategy(strategy_name, strategy_js)
      end
    end
  end
end
