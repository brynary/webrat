require "hpricot"
require "English"

module ActionController
  module Integration
   
    class Session
      # Issues a GET request for a page, follows any redirects, and verifies the final page
      # load was successful.
      #
      # Example:
      #   visits "/"
      def visits(path)
        request_page(:get, path)
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
        return flunk("No value was provided") if value.nil?
        input = find_field_by_name_or_label(field)
        return flunk("Could not find input #{field.inspect}") if input.nil?
        add_form_data(input, value)
        # TODO - Set current form
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
          return flunk("Could not find select list #{options[:from].inspect}") if select.nil?
          option_node = find_option_by_value(option_text, select)
          return flunk("Could not find option #{option_text.inspect}") if option_node.nil?
        else
          option_node = find_option_by_value(option_text)
          return flunk("Could not find option #{option_text.inspect}") if option_node.nil?
          select = option_node.parent
        end
        add_form_data(select, option_node.attributes["value"] || option_node.innerHTML)
        # TODO - Set current form
      end
      
      # Verifies that an input checkbox exists on the current page and marks it
      # as checked, so that the value will be submitted with the form.
      #
      # Example:
      #   checks 'Remember Me'
      def checks(field)
        checkbox = find_field_by_name_or_label(field)
        return flunk("Could not find checkbox #{field.inspect}") if checkbox.nil?
        return flunk("Input #{checkbox.inspect} is not a checkbox") unless checkbox.attributes['type'] == 'checkbox'
        add_form_data(checkbox, checkbox.attributes["value"] || "on")
      end
      
      # Verifies that an input checkbox exists on the current page and marks it
      # as unchecked, so that the value will not be submitted with the form.
      #
      # Example:
      #   unchecks 'Remember Me'
      def unchecks(field)
        checkbox = find_field_by_name_or_label(field)
        return flunk("Could not find checkbox #{field.inspect}") if checkbox.nil?
        return flunk("Input #{checkbox.inspect} is not a checkbox") unless checkbox.attributes['type'] == 'checkbox'
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
        return flunk("Could not find radio button #{field.inspect}") if radio.nil?
        return flunk("Input #{radio.inspect} is not a radio button") unless radio.attributes['type'] == 'radio'
        add_form_data(radio, radio.attributes["value"] || "on")
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
        button = value ? find_button(value) : submit_buttons.first
        return flunk("Could not find button #{value.inspect}") if button.nil?
        add_form_data(button, button.attributes["value"]) unless button.attributes["name"].blank?
        submit_form(form_for_node(button))
      end
      
      def submits_form(form_id = nil) # :nodoc:
      end
      
      # Saves the currently loaded page out to RAILS_ROOT/tmp/ and opens it in the default
      # web browser if on OS X. Useful for debugging.
      # 
      # Example:
      #   save_and_open_page
      def save_and_open_page
        return unless File.exist?(RAILS_ROOT + "/tmp")

        filename = "webrat-#{Time.now.to_i}.html"
        File.open(RAILS_ROOT + "/tmp/#{filename}", "w") do |f|
          f.write response.body
        end
        `open tmp/#{filename}`
      end

      # Reloads the last page requested. Note that this will resubmit forms
      # and their data.
      #
      # Example:
      #   reloads
      def reloads
        request_page(*@last_request_args) if defined?(@last_request_args) && @last_request_args
      end

    protected # Methods you could call, but probably shouldn't
    
      def authenticity_token_value(onclick)
        return unless onclick && onclick.include?("s.setAttribute('name', 'authenticity_token');") &&
          onclick =~ /s\.setAttribute\('value', '([a-f0-9]{40})'\);/
        $LAST_MATCH_INFO.captures.first
      end
      
      def http_method_from_js(onclick) 
        if !onclick.blank? && onclick.include?("f.submit()")
          http_method_from_js_form(onclick)
        else
          :get
        end
      end
      
      def http_method_from_js_form(onclick)
        if onclick.include?("m.setAttribute('name', '_method')")
          http_method_from_fake_method_param(onclick)
        else
          :post
        end
      end
      
      def http_method_from_fake_method_param(onclick)
        if onclick.include?("m.setAttribute('value', 'delete')")
          :delete
        elsif onclick.include?("m.setAttribute('value', 'put')")
          :put
        else
          raise "No HTTP method for _method param in #{onclick.inspect}"
        end
      end
      
      def clicks_link_with_method(link_text, http_method) # :nodoc:
        link = all_links.detect { |el| el.innerHTML =~ /#{link_text}/i }
        return flunk("No link with text #{link_text.inspect} was found") if link.nil?
        request_page(http_method, link.attributes["href"])
      end
      
      def find_shortest_matching_link(links, link_text)
        candidates = links.select { |el| el.innerHTML =~ /#{link_text}/i }
        candidates.sort_by { |el| el.innerText.strip.size }.first
      end
      
      def clicks_one_link_of(links, link_text)
        link = find_shortest_matching_link(links, link_text)
        
        return flunk("No link with text #{link_text.inspect} was found") if link.nil?
        
        onclick = link.attributes["onclick"]
        href    = link.attributes["href"]
        
        http_method = http_method_from_js(onclick)
        authenticity_token = authenticity_token_value(onclick)
        
        request_page(http_method, href, authenticity_token.blank? ? {} : {"authenticity_token" => authenticity_token}) unless href =~ /^#/ && http_method == :get
      end
      
      def find_field_by_name_or_label(name_or_label) # :nodoc:
        input = find_field_by_name(name_or_label)
        return input if input
      
        label = find_form_label(name_or_label)
        label ? input_for_label(label) : nil
      end

      def find_select_list_by_name_or_label(name_or_label) # :nodoc:
        select = find_select_list_by_name(name_or_label)
        return select if select
        
        label = find_form_label(name_or_label)
        label ? select_list_for_label(label) : nil
      end
        
      def find_option_by_value(option_value, select=nil) # :nodoc:
        options = select.nil? ? option_nodes : (select / "option")
        options.detect { |el| el.innerHTML == option_value }
      end
      
      def find_button(value = nil) # :nodoc:
        return nil unless value
        submit_buttons.detect { |el| el.attributes["value"] =~ /^\W*#{value}\b/i }
      end
      
      def add_form_data(input_element, value) # :nodoc:
        form = form_for_node(input_element)
        data = param_parser.parse_query_parameters("#{input_element.attributes["name"]}=#{value}")
        merge_form_data(form_number(form), data)
      end

      def remove_form_data(input_element) # :nodoc:
        form = form_for_node(input_element)
        form_number = form_number(form)
        form_data[form_number] ||= {}
        form_data[form_number].delete(input_element.attributes['name'])
      end
      
      def submit_form(form) # :nodoc:
        form_number = form_number(form)
        request_page(form_method(form), form_action(form), form_data[form_number])
      end
      
      def merge_form_data(form_number, data) # :nodoc:
        form_data[form_number] ||= {}
        
        data.each do |key, value|
          case form_data[form_number][key]
          when Hash, HashWithIndifferentAccess; then merge(form_data[form_number][key], value)
          when Array; then form_data[form_number][key] += value
          else form_data[form_number][key] = value
          end
        end
      end
      
      def merge(a, b) # :nodoc:
        a.keys.each do |k|
          if b.has_key?(k)
            case [a[k], b[k]].map(&:class)
            when [Hash, Hash]
              a[k] = merge(a[k], b[k])
              b.delete(k)
            when [Array, Array]
              a[k] += b[k]
              b.delete(k)
            end
          end
        end
        a.merge!(b)
      end
      
      def request_page(method, url, data = {}) # :nodoc:
        debug_log "REQUESTING PAGE: #{method.to_s.upcase} #{url} with #{data.inspect}"
        @current_url = url
        @last_request_args = [method, url, data]
        self.send "#{method}_via_redirect", @current_url, data || {}
        
        if response.body =~ /Exception caught/ || response.body.blank? 
          save_and_open_page
       	end
       	
       	assert_response :success
        reset_dom
      end
      
      def input_for_label(label) # :nodoc:
        if input = (label / "input").first
          input # nested inputs within labels
        else
          # input somewhere else, referenced by id
          input_id = label.attributes["for"]
          (dom / "##{input_id}").first
        end
      end

      def select_list_for_label(label) # :nodoc:
        if select_list = (label / "select").first
          select_list # nested inputs within labels
        else
          # input somewhere else, referenced by id
          select_list_id = label.attributes["for"]
          (dom / "##{select_list_id}").first
        end
      end

      def param_parser # :nodoc:
        if defined?(CGIMethods)
          CGIMethods
        else
          ActionController::AbstractRequest
        end
      end
      
      def submit_buttons # :nodoc:
        input_fields.select { |el| el.attributes["type"] == "submit" }
      end
      
      def find_field_by_name(name) # :nodoc:
        find_input_by_name(name) || find_textarea_by_name(name)
      end
      
      def find_input_by_name(name) # :nodoc:
        input_fields.detect { |el| el.attributes["name"] == name }
      end
      
      def find_select_list_by_name(name) # :nodoc:
        select_lists.detect { |el| el.attributes["name"] == name }
      end
      
      def find_textarea_by_name(name) # :nodoc:
        textarea_fields.detect{ |el| el.attributes['name'] == name }
      end
      
      def find_form_label(text) # :nodoc:
        candidates = form_labels.select { |el| el.innerText =~ /^\W*#{text}\b/i }
        candidates.sort_by { |el| el.innerText.strip.size }.first
      end
      
      def form_action(form) # :nodoc:
        form.attributes["action"].blank? ? current_url : form.attributes["action"]
      end
      
      def form_method(form) # :nodoc:
        form.attributes["method"].blank? ? :get : form.attributes["method"].downcase
      end
      
      def add_default_params # :nodoc:
        (dom / "form").each do |form|
          add_default_params_for(form)
        end
      end
      
      def add_default_params_for(form) # :nodoc:
        add_default_params_from_inputs_for(form)
        add_default_params_from_checkboxes_for(form)
        add_default_params_from_radio_buttons_for(form)
        add_default_params_from_textareas_for(form)
        add_default_params_from_selects_for(form)
      end
      
      def add_default_params_from_inputs_for(form) # :nodoc:
        (form / "input").each do |input|
          next unless %w[text hidden].include?(input.attributes["type"])
          add_form_data(input, input.attributes["value"])
        end
      end
      
      def add_default_params_from_checkboxes_for(form) # :nodoc:
        (form / "input[@type='checkbox][@checked='checked']").each do |input|
          add_form_data(input, input.attributes["value"] || "on")
        end
      end
      
      def add_default_params_from_radio_buttons_for(form) # :nodoc:
        (form / "input[@type='radio][@checked='checked']").each do |input|
          add_form_data(input, input.attributes["value"])
        end
      end
      
      def add_default_params_from_textareas_for(form) # :nodoc:
        (form / "textarea").each do |input|
          add_form_data(input, input.inner_html)
        end
      end
      
      def add_default_params_from_selects_for(form) # :nodoc:
        (form / "select").each do |select|
          selected_options = select / "option[@selected='selected']"
          selected_options = select / "option:first" if selected_options.empty? 
          selected_options.each do |option|
            add_form_data(select, option.attributes["value"] || option.innerHTML)
          end
        end
      end
      
      def form_for_node(node) # :nodoc:
        return node if node.name == "form"
        node = node.parent until node.name == "form"
        node
      end
      
      def reset_dom # :nodoc:
        @form_data = []
        @dom = nil
      end
      
      def form_data # :nodoc:
        @form_data ||= []
      end
      
      def all_links # :nodoc:
        (dom / "a[@href]")
      end

      def links_within(selector) # :nodoc:
        (dom / selector / "a[@href]")
      end
      
      def form_number(form) # :nodoc:
        (dom / "form").index(form)
      end
      
      def input_fields # :nodoc:
        (dom / "input")
      end
      
      def textarea_fields # :nodoc
        (dom / "textarea")
      end
      
      def form_labels # :nodoc:
        (dom / "label")
      end

      def select_lists # :nodoc:
        (dom / "select")
      end

      def option_nodes # :nodoc:
        (dom / "option")
      end

      def dom # :nodoc:
        return @dom if defined?(@dom) && @dom
        raise "You must visit a path before working with the page." unless response
        @dom = Hpricot(response.body)
        add_default_params
        @dom
      end

      def debug_log(message) # :nodoc:
        return unless logger
        logger.debug
      end
      
      def logger # :nodoc:
        if defined? RAILS_DEFAULT_LOGGER
          RAILS_DEFAULT_LOGGER
        else
          nil
        end
      end
      
    end
      
  end
end
