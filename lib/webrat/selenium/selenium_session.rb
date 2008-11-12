module Webrat
  class SeleniumSession
    
    def initialize(selenium_driver) #:nodoc:
      @selenium = selenium_driver
      extend_selenium
      define_location_strategies
    end
    
    def visit(url)
      @selenium.open(url)
    end
    
    alias_method :visits, :visit
    
    def fill_in(field_identifier, options)
      locator = "webrat=#{Regexp.escape(field_identifier)}"
      @selenium.type(locator, "#{options[:with]}")
    end
    
    alias_method :fills_in, :fill_in
    
    def response_body #:nodoc:
      @selenium.get_html_source
    end
    
    def click_button(button_text_or_regexp = nil, options = {})
      if button_text_or_regexp.is_a?(Hash) && options == {}
        pattern, options = nil, button_text_or_regexp
      else
        pattern = adjust_if_regexp(button_text_or_regexp)
      end
      pattern ||= '*'
      @selenium.click("button=#{pattern}")
      wait_for_result(options[:wait])
    end
    
    alias_method :clicks_button, :click_button

    def click_link(link_text_or_regexp, options = {})
      pattern = adjust_if_regexp(link_text_or_regexp)
      @selenium.click("webratlink=#{pattern}")
      wait_for_result(options[:wait])
    end
    
    alias_method :clicks_link, :click_link
    
    def click_link_within(selector, link_text, options = {})
      @selenium.click("webratlinkwithin=#{selector}|#{link_text}")
      wait_for_result(options[:wait])
    end
    
    alias_method :clicks_link_within, :click_link_within

    def wait_for_result(wait_type)
      if wait_type == :ajax
        wait_for_ajax
      elsif wait_type == :effects
        wait_for_effects
      else
        wait_for_page_to_load
      end
    end

    def wait_for_page_to_load(timeout = 15000)
      @selenium.wait_for_page_to_load(timeout)
    end

    def wait_for_ajax(timeout = 15000)
      @selenium.wait_for_condition "Ajax.activeRequestCount == 0", timeout
    end

    def wait_for_effects(timeout = 15000)
      @selenium.wait_for_condition "window.Effect.Queue.size() == 0", timeout
    end

    def wait_for_ajax_and_effects
      wait_for_ajax
      wait_for_effects
    end    
    
    def selects(option_text, options = {})
      id_or_name_or_label = options[:from]
      
      if id_or_name_or_label
        select_locator = "webrat=#{id_or_name_or_label}"
      else
        select_locator = "webratselectwithoption=#{option_text}"
      end
      @selenium.select(select_locator, option_text)
    end
    
    def choose(label_text)
      @selenium.click("webrat=#{label_text}")
    end
    
    alias_method :chooses, :choose
        
    def check(label_text)
      @selenium.check("webrat=#{label_text}")
    end
    
    alias_method :checks, :check
    
    def is_ordered(*args) #:nodoc:
      @selenium.is_ordered(*args)
    end
    
    def dragdrop(*args) #:nodoc:
      @selenium.dragdrop(*args)
    end
        
  protected
    
    def adjust_if_regexp(text_or_regexp) #:nodoc:
      if text_or_regexp.is_a?(Regexp)
        "evalregex:#{text_or_regexp.inspect}"
      else
        text_or_regexp
      end 
    end
    
    def extend_selenium #:nodoc:
      extensions_file = File.join(File.dirname(__FILE__), "selenium_extensions.js")
      extenions_js = File.read(extensions_file)
      @selenium.get_eval(extenions_js)
    end
    
    def define_location_strategies #:nodoc:
      Dir[File.join(File.dirname(__FILE__), "location_strategy_javascript", "*.js")].sort.each do |file|
        strategy_js = File.read(file)
        strategy_name = File.basename(file, '.js')
        @selenium.add_location_strategy(strategy_name, strategy_js)
      end
    end
  end
end