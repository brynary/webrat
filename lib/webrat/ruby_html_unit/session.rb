module RubyHtmlUnit
  
  class Session
    attr_accessor :response, :current_page, :alert_handler
    
    include ActionController::UrlWriter
    include ActionController::Assertions
    include Test::Unit::Assertions
    
    
    class << self
      def rewrite_url(url)
        if url =~ %r{^(/.*)} || url =~ %r{^https?://www.example.com(/.*)}
          append_to_root_url($1)
        else
          url
        end
      end
      
      def append_to_root_url(path)
        path = "/#{path}" unless path =~ /^\//
        "http://localhost:#{TEST_SERVER_PORT}#{path}"
      end
    end
    
    def initialize()
      #java.lang.System.getProperties.put("org.apache.commons.logging.simplelog.defaultlog", opts[:log_level] ? opts[:log_level].to_s : "warn")
      java.lang.System.getProperties.put("org.apache.commons.logging.simplelog.defaultlog", "warn")
      
      browser = ::HtmlUnit::BrowserVersion::FIREFOX_2
      @webclient = ::HtmlUnit::WebClient.new(browser)
      @webclient.setThrowExceptionOnScriptError(false)       #unless opts[:javascript_exceptions]
      @webclient.setThrowExceptionOnFailingStatusCode(false) #unless opts[:status_code_exceptions]
      @webclient.setCssEnabled(false)                        #unless opts[:css]
      @webclient.setUseInsecureSSL(true)                     #if opts[:secure_ssl]
      
      @alert_handler = AlertHandler.new
      
      @webclient.setAlertHandler(@alert_handler)
      
      @response = nil
      @current_page = nil
    end
    
    def visits(url)
      update_page(@webclient.getPage(Session.rewrite_url(url)))
    end
    
    def clicks_link(text)
      link = @current_page.find_link(text)
      update_page(link.click)
    end
    
    def clicks_button(text = nil)
      button = @current_page.find_button(text)
      update_page(button.click)
    end
    
    def fills_in(id_or_name_or_label, options = {})
      field = @current_page.find_field(id_or_name_or_label, :text)
      update_page(field.fill_in_with(options[:with]))
    end
    
    def selects(option_text, options = {})
      id_or_name_or_label = options[:from]
      
      select_tag = @current_page.find_select_list_with_option(option_text, id_or_name_or_label)
      
      flunk("Could not find option #{option_text.inspect}") if select_tag.nil?
      select_tag.select(option_text)
    end
    
    def chooses(label)
      field = @current_page.find_field(label, :radio)
      update_page(field.set)
    end

    def checks(id_or_name_or_label)
      field = @current_page.find_field(id_or_name_or_label, :checkbox)
      update_page(field.set(true))
    end
    
    def unchecks(id_or_name_or_label)
      field = @current_page.find_field(id_or_name_or_label, :checkbox)
      update_page(field.set(false))
    end
    
    def get_element(dom_id)
      @current_page.elements_by_xpath("//*[@id='#{dom_id}']").first
    end
    alias_method :get_element_by_id, :get_element
    
    def wait_for_result(wait_type)
      # No support for different types of waiting right now
      sleep(0.5)
      # if wait_type == :ajax
      #   wait_for_ajax
      # elsif wait_type == :effects
      #   wait_for_effects
      # else
      #   wait_for_page_to_load
      # end
    end
    
    def update_page(html_unit_page)
      @current_page = Page.new(html_unit_page)
      @response = Response.new(html_unit_page.getWebResponse)
    end
    
    def save_and_open_page
      @current_page.save_and_open
    end
    
    def respond_to?(method)
      super || @current_page.respond_to?(method)
    end
    
    def method_missing(name, *args)
      if @current_page.respond_to?(name)
        @current_page.send(name, *args)
      else
        super
      end
    end
  end
  
end