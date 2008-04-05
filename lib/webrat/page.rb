require "hpricot"
require "English"

module Webrat
  class Page
    include Logging

    attr_reader :session
    
    def initialize(session, url = nil, method = :get, data = {})
      @session  = session
      @url      = url
      @method   = method
      @data     = data
      
      reset_dom
      reloads if @url
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
    def fills_in(field, options = {})
      value = options[:with]
      flunk("No value was provided") if value.nil?
      
      form_with_input = nil
      found_input = nil
      
      forms.each do |form|
        found_input = form.find_field(field, %w[input textarea], %w[text password])
        
        if found_input
          form_with_input = form
          break
        end
      end
      
      flunk("Could not find input #{field.inspect}") if found_input.nil?
      
      form_with_input.set(found_input, value)
    end

    # Verifies that an input checkbox exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   checks 'Remember Me'
    def checks(field)
      checkbox = find_field_by_name_or_label(field)
      flunk("Could not find checkbox #{field.inspect}") if checkbox.nil?
      flunk("Input #{checkbox.inspect} is not a checkbox") unless checkbox.attributes['type'] == 'checkbox'
      add_form_data(checkbox, checkbox.attributes["value"] || "on")
    end

    # Verifies that an input checkbox exists on the current page and marks it
    # as unchecked, so that the value will not be submitted with the form.
    #
    # Example:
    #   unchecks 'Remember Me'
    def unchecks(field)
      checkbox = find_field_by_name_or_label(field)
      flunk("Could not find checkbox #{field.inspect}") if checkbox.nil?
      flunk("Input #{checkbox.inspect} is not a checkbox") unless checkbox.attributes['type'] == 'checkbox'
      remove_form_data(checkbox)

      (form_for_node(checkbox) / "input").each do |input|
        next unless input.attributes["type"] == "hidden" && input.attributes["name"] == checkbox.attributes["name"]
        add_form_data(input, input.attributes["value"])
      end
    end

    # Verifies that an input radio button exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   chooses 'First Option'
    def chooses(field)
      radio = find_field_by_name_or_label(field)
      flunk("Could not find radio button #{field.inspect}") if radio.nil?
      flunk("Input #{radio.inspect} is not a radio button") unless radio.attributes['type'] == 'radio'
      add_form_data(radio, radio.attributes["value"] || "on")
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
      if options[:from]
        select = find_select_list_by_name_or_label(options[:from])
        flunk("Could not find select list #{options[:from].inspect}") if select.nil?
        option_node = find_option_by_value(option_text, select)
        flunk("Could not find option #{option_text.inspect}") if option_node.nil?
      else
        option_node = find_option_by_value(option_text)
        flunk("Could not find option #{option_text.inspect}") if option_node.nil?
        select = option_node.parent
      end
      add_form_data(select, option_node.attributes["value"] || option_node.innerHTML)
      # TODO - Set current form
    end

    # Saves the currently loaded page out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. Useful for debugging.
    # 
    # Example:
    #   save_and_open
    def save_and_open
      return unless File.exist?(RAILS_ROOT + "/tmp")

      filename = "webrat-#{Time.now.to_i}.html"
      File.open(RAILS_ROOT + "/tmp/#{filename}", "w") do |f|
        f.write response.body
      end
      `open tmp/#{filename}`
    end

    # Issues a request for the URL pointed to by a link on the current page,
    # follows any redirects, and verifies the final page load was successful.
    #
    # clicks_link has very basic support for detecting Rails-generated 
    # JavaScript onclick handlers for PUT, POST and DELETE links, as well as
    # CSRF authenticity tokens if they are present.
    #
    # Example:
    #   clicks_link "Sign up"
    def clicks_link(link_text)
      clicks_one_link_of(all_links, link_text)
    end

    # Works like clicks_link, but only looks for the link text within a given selector
    # 
    # Example:
    #   clicks_link_within "#user_12", "Vote"
    def clicks_link_within(selector, link_text)
      clicks_one_link_of(links_within(selector), link_text)
    end

    # Works like clicks_link, but forces a GET request
    # 
    # Example:
    #   clicks_get_link "Log out"
    def clicks_get_link(link_text)
      clicks_link_with_method(link_text, :get)
    end

    # Works like clicks_link, but issues a DELETE request instead of a GET
    # 
    # Example:
    #   clicks_delete_link "Log out"
    def clicks_delete_link(link_text)
      clicks_link_with_method(link_text, :delete)
    end

    # Works like clicks_link, but issues a POST request instead of a GET
    # 
    # Example:
    #   clicks_post_link "Vote"
    def clicks_post_link(link_text)
      clicks_link_with_method(link_text, :post)
    end

    # Works like clicks_link, but issues a PUT request instead of a GET
    # 
    # Example:
    #   clicks_put_link "Update profile"
    def clicks_put_link(link_text)
      clicks_link_with_method(link_text, :put)
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
      form_with_button = nil
      found_button = nil
      
      forms.each do |form|
        found_button = form.find_button(value)
        
        if found_button
          form_with_button = form
          break
        end
      end

      flunk("Could not find button #{value.inspect}") if found_button.nil?
      form_with_button.set(found_button, found_button.attributes["value"]) unless found_button.attributes["name"].blank?
      form_with_button.submit
    end

    # Reloads the last page requested. Note that this will resubmit forms
    # and their data.
    #
    # Example:
    #   reloads
    def reloads
      request_page(@url, @method, @data)
    end

    def submits_form(form_id = nil) # :nodoc:
    end

  protected

    def request_page(url, method, data)
      debug_log "REQUESTING PAGE: #{method.to_s.upcase} #{url} with #{data.inspect}"
      
      session.send "#{method}_via_redirect", url, data || {}

      if response.body =~ /Exception caught/ || response.body.blank? 
        save_and_open
      end

      session.assert_response :success
      reset_dom
    end
    
    def response
      session.response
    end
    
    def reset_dom
      @dom    = nil
      @forms  = nil
    end
    
    def find_button(value = nil) # :nodoc:
      return nil unless value

      (dom / "input[@type='submit']").detect do |el|
        el.attributes["value"] =~ /^\W*#{value}\b/i
      end
    end

    def form_for_node(node) # :nodoc:
      return node if node.name == "form"
      node = node.parent until node.name == "form"
      node
    end
    
    def forms
      return @forms if @forms
      
      @forms = (dom / "form").map do |form_element|
        Form.new(self, form_element)
      end
    end
      
    def dom # :nodoc:
      return @dom if defined?(@dom) && @dom
      flunk("You must visit a path before working with the page.") unless @session.response
      @dom = Hpricot(@session.response.body)
    end
    
    def flunk(message)
      raise message
    end
    
  end
end