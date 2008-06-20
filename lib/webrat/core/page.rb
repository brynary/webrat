require "rubygems"
require "hpricot"
require "English"

module Webrat
  class Page
    include Logging

    attr_reader :session
    attr_reader :url
    
    def initialize(session, url = nil, method = :get, data = {})
      @session  = session
      @url      = url
      @method   = method
      @data     = data

      reset_dom
      load_page if @url
      
      session.current_page = self
    end
    
    # Verifies an input field or textarea exists on the current page, and stores a value for
    # it which will be sent when the form is submitted.
    #
    # Examples:
    #   fills_in "Email", :with => "user@example.com"
    #   fills_in "user[email]", :with => "user@example.com"
    #
    # The field value is required, and must be specified in <tt>options[:with]</tt>.
    # <tt>field</tt> can be either the value of a name attribute (i.e. <tt>user[email]</tt>)
    # or the text inside a <tt><label></tt> element that points at the <tt><input></tt> field.
    def fills_in(id_or_name_or_label, options = {})
      field = find_field(id_or_name_or_label, TextField, TextareaField, PasswordField)
      field.set(options[:with])
    end

    # Verifies that an input checkbox exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   checks 'Remember Me'
    def checks(id_or_name_or_label)
      field = find_field(id_or_name_or_label, CheckboxField)
      field.check
    end

    # Verifies that an input checkbox exists on the current page and marks it
    # as unchecked, so that the value will not be submitted with the form.
    #
    # Example:
    #   unchecks 'Remember Me'
    def unchecks(id_or_name_or_label)
      field = find_field(id_or_name_or_label, CheckboxField)
      field.uncheck
    end

    # Verifies that an input radio button exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   chooses 'First Option'
    def chooses(label)
      field = find_field(label, RadioField)
      field.choose
    end

    # Verifies that a an option element exists on the current page with the specified
    # text. You can optionally restrict the search to a specific select list by
    # assigning <tt>options[:from]</tt> the value of the select list's name or
    # a label. Stores the option's value to be sent when the form is submitted.
    #
    # Examples:
    #   selects "January"
    #   selects "February", :from => "event_month"
    #   selects "February", :from => "Event Month"
    def selects(option_text, options = {})
      id_or_name_or_label = options[:from]
      
      if id_or_name_or_label
        field = find_field(id_or_name_or_label, SelectField)
        option = field.find_option(option_text)
      else
        option = find_select_option(option_text)
      end
        
      flunk("Could not find option #{option_text.inspect}") if option.nil?
      option.choose
    end

    # Verifies that an input file field exists on the current page and sets
    # its value to the given +file+, so that the file will be uploaded
    # along with the form.
    #
    # Example:
    #   attaches_file "Photo", "/path/to/the/photo.jpg"
    def attaches_file(id_or_name_or_label, path)
      field = find_field(id_or_name_or_label, FileField)
      field.set(path)
    end

    # Saves the page out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. Useful for debugging.
    # 
    # Example:
    #   save_and_open
    def save_and_open
      return unless File.exist?(session.saved_page_dir)

      filename = "#{session.saved_page_dir}/webrat-#{Time.now.to_i}.html"
      
      File.open(filename, "w") do |f|
        f.write rewrite_css_and_image_references(session.response_body)
      end

      open_in_browser(filename)
    end
    
    def open_in_browser(path) # :nodoc
      `open #{path}`
    end

    # Issues a request for the URL pointed to by a link on the current page,
    # follows any redirects, and verifies the final page load was successful.
    #
    # clicks_link has very basic support for detecting Rails-generated 
    # JavaScript onclick handlers for PUT, POST and DELETE links, as well as
    # CSRF authenticity tokens if they are present.
    #
    # Javascript imitation can be disabled by passing the option :javascript => false
    #
    # Example:
    #   clicks_link "Sign up"
    #
    #   clicks_link "Sign up", :javascript => false
    def clicks_link(link_text, options = {})
      link = find_link(link_text)
      link.click(nil, options)
    end

    # Works like clicks_link, but only looks for the link text within a given selector
    # 
    # Example:
    #   clicks_link_within "#user_12", "Vote"
    def clicks_link_within(selector, link_text)
      link = find_link(link_text, selector)
      link.click
    end

    # Works like clicks_link, but forces a GET request
    # 
    # Example:
    #   clicks_get_link "Log out"
    def clicks_get_link(link_text)
      link = find_link(link_text)
      link.click(:get)
    end

    # Works like clicks_link, but issues a DELETE request instead of a GET
    # 
    # Example:
    #   clicks_delete_link "Log out"
    def clicks_delete_link(link_text)
      link = find_link(link_text)
      link.click(:delete)
    end

    # Works like clicks_link, but issues a POST request instead of a GET
    # 
    # Example:
    #   clicks_post_link "Vote"
    def clicks_post_link(link_text)
      link = find_link(link_text)
      link.click(:post)
    end

    # Works like clicks_link, but issues a PUT request instead of a GET
    # 
    # Example:
    #   clicks_put_link "Update profile"
    def clicks_put_link(link_text)
      link = find_link(link_text)
      link.click(:put)
    end

    # Verifies that a submit button exists for the form, then submits the form, follows
    # any redirects, and verifies the final page was successful.
    #
    # Example:
    #   clicks_button "Login"
    #   clicks_button
    #
    # The URL and HTTP method for the form submission are automatically read from the
    # <tt>action</tt> and <tt>method</tt> attributes of the <tt><form></tt> element.
    def clicks_button(value = nil)
      button = nil
      
      forms.each do |form|
        button = form.find_button(value)
        break if button
      end

      flunk("Could not find button #{value.inspect}") if button.nil?
      button.click
    end

    # Reloads the last page requested. Note that this will resubmit forms
    # and their data.
    #
    # Example:
    #   reloads
    def reloads
      load_page
    end

    def submits_form(form_id = nil) # :nodoc:
    end

  protected
  
    def load_page
      request_page(@url, @method, @data)
    end
    
    def find_select_option(option_text)
      forms.each do |form|
        result = form.find_select_option(option_text)
        return result if result
      end
      
      nil
    end
  
    
    def find_link(text, selector = nil)
      matching_links = []
      
      links_within(selector).each do |possible_link|
        matching_links << possible_link if possible_link.matches_text?(text)
      end
      
      if matching_links.any?
        matching_links.sort_by { |l| l.text.length }.first
      else
        flunk("Could not find link with text #{text.inspect}")
      end
    end
    
    def find_field(id_or_name_or_label, *field_types)
      forms.each do |form|
        result = form.find_field(id_or_name_or_label, *field_types)
        return result if result
      end
      
      flunk("Could not find #{field_types.inspect}: #{id_or_name_or_label.inspect}")
    end
    
    def request_page(url, method, data)
      debug_log "REQUESTING PAGE: #{method.to_s.upcase} #{url} with #{data.inspect}"
      
      session.send "#{method}", url, data || {}

      if session.response_body =~ /Exception caught/ || session.response_body.blank? 
        save_and_open
      end

      flunk("Page load was not successful (Code: #{session.response_code.inspect})") unless (200..299).include?(session.response_code)
      reset_dom
    end
    
    def reset_dom
      @dom    = nil
      @forms  = nil
    end
    
    def links_within(selector)
      (dom / selector / "a[@href]").map do |link_element|
        Link.new(self, link_element)
      end
    end
    
    def forms
      return @forms if @forms
      
      @forms = (dom / "form").map do |form_element|
        Form.new(self, form_element)
      end
    end
      
    def dom # :nodoc:
      return @dom if defined?(@dom) && @dom
      flunk("You must visit a path before working with the page.") unless @session.response_code
      @dom = Hpricot(@session.response_body)
    end
    
    def flunk(message)
      raise message
    end
    
    def rewrite_css_and_image_references(response_html) # :nodoc
      return response_html unless session.doc_root
      response_html.gsub(/"\/(stylesheets|images)/, session.doc_root + '/\1')
    end
    
  end
end