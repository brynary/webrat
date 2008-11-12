require "webrat/core/form"
require "webrat/core/locators"

module Webrat
  class Scope
    include Logging
    include Flunk
    include Locators
    
    def self.from_page(session, response, response_body) #:nodoc:
      new(session) do
        @response = response
        @response_body = response_body
      end
    end
    
    def self.from_scope(session, scope, selector) #:nodoc:
      new(session) do
        @scope = scope
        @selector = selector
      end
    end
    
    def initialize(session, &block) #:nodoc:
      @session = session
      instance_eval(&block) if block_given?
    end
    
    # Verifies an input field or textarea exists on the current page, and stores a value for
    # it which will be sent when the form is submitted.
    #
    # Examples:
    #   fill_in "Email", :with => "user@example.com"
    #   fill_in "user[email]", :with => "user@example.com"
    #
    # The field value is required, and must be specified in <tt>options[:with]</tt>.
    # <tt>field</tt> can be either the value of a name attribute (i.e. <tt>user[email]</tt>)
    # or the text inside a <tt><label></tt> element that points at the <tt><input></tt> field.
    def fill_in(field_locator, options = {})
      field = locate_field(field_locator, TextField, TextareaField, PasswordField)
      field.raise_error_if_disabled
      field.set(options[:with])
    end

    alias_method :fills_in, :fill_in
    
    # Verifies that an input checkbox exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   check 'Remember Me'
    def check(field_locator)
      locate_field(field_locator, CheckboxField).check
    end

    alias_method :checks, :check
    
    # Verifies that an input checkbox exists on the current page and marks it
    # as unchecked, so that the value will not be submitted with the form.
    #
    # Example:
    #   uncheck 'Remember Me'
    def uncheck(field_locator)
      locate_field(field_locator, CheckboxField).uncheck
    end

    alias_method :unchecks, :uncheck
    
    # Verifies that an input radio button exists on the current page and marks it
    # as checked, so that the value will be submitted with the form.
    #
    # Example:
    #   choose 'First Option'
    def choose(field_locator)
      locate_field(field_locator, RadioField).choose
    end

    alias_method :chooses, :choose
    
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
      find_select_option(option_text, options[:from]).choose
    end

    alias_method :select, :selects
    
    # Verifies that an input file field exists on the current page and sets
    # its value to the given +file+, so that the file will be uploaded
    # along with the form. An optional <tt>content_type</tt> may be given.
    #
    # Example:
    #   attaches_file "Resume", "/path/to/the/resume.txt"
    #   attaches_file "Photo", "/path/to/the/image.png", "image/png"
    def attach_file(field_locator, path, content_type = nil)
      locate_field(field_locator, FileField).set(path, content_type)
    end

    alias_method :attaches_file, :attach_file
    
    def click_area(area_name)
      find_area(area_name).click
    end
    
    alias_method :clicks_area, :click_area
    
    # Issues a request for the URL pointed to by a link on the current page,
    # follows any redirects, and verifies the final page load was successful.
    # 
    # click_link has very basic support for detecting Rails-generated 
    # JavaScript onclick handlers for PUT, POST and DELETE links, as well as
    # CSRF authenticity tokens if they are present.
    #
    # Javascript imitation can be disabled by passing the option :javascript => false
    #
    # Passing a :method in the options hash overrides the HTTP method used
    # for making the link request
    # 
    # Example:
    #   click_link "Sign up"
    #
    #   click_link "Sign up", :javascript => false
    # 
    #   click_link "Sign up", :method => :put
    def click_link(link_text, options = {})
      find_link(link_text).click(options)
    end

    alias_method :clicks_link, :click_link
    
    # Verifies that a submit button exists for the form, then submits the form, follows
    # any redirects, and verifies the final page was successful.
    #
    # Example:
    #   click_button "Login"
    #   click_button
    #
    # The URL and HTTP method for the form submission are automatically read from the
    # <tt>action</tt> and <tt>method</tt> attributes of the <tt><form></tt> element.
    def click_button(value = nil)
      find_button(value).click
    end

    alias_method :clicks_button, :click_button
    
    def dom # :nodoc:
      return @dom if @dom
      
      if @selector
        @dom = scoped_dom
      else
        @dom = page_dom
      end
      
      return @dom
    end
    
  protected
  
    def page_dom #:nodoc:
      return @response.dom if @response.respond_to?(:dom)
      dom = Webrat.nokogiri_document(@response_body)
      Webrat.define_dom_method(@response, dom)
      return dom
    end
    
    def scoped_dom #:nodoc:
      Webrat.nokogiri_document(@scope.dom.search(@selector).first.to_html)
    end
    
    def locate_field(field_locator, *field_types) #:nodoc:
      if field_locator.is_a?(Field)
        field_locator
      else
        field(field_locator, *field_types)
      end
    end
    
    def areas #:nodoc:
      dom.search("area").map do |element| 
        Area.new(@session, element)
      end
    end
    
    def links #:nodoc:
      dom.search("a[@href]").map do |link_element|
        Link.new(@session, link_element)
      end
    end
    
    def forms #:nodoc:
      return @forms if @forms
      
      @forms = dom.search("form").map do |form_element|
        Form.new(@session, form_element)
      end
    end
    
  end
end