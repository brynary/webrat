Webrat
======

- [Code on GitHub](http://github.com/brynary/webrat)
- [Tickets on Lighthouse](http://webrat.lighthouseapp.com/)

Description
-----------

Webrat (_Ruby Acceptance Testing for Web applications_)
lets you quickly write robust and thorough acceptance tests for a Ruby
web application. By leveraging the DOM, it can run tests similarly to an
in-browser testing solution without the associated performance hit (and
browser dependency). The result is tests that are less fragile and more
effective at verifying that the app will respond properly to users.

When comparing Webrat with an in-browser testing solution like Watir or
Selenium, the primary consideration should be how much JavaScript the
application uses. In-browser testing is currently the only way to test JS, and
that may make it a requirement for your project. If JavaScript is not central
to your application, Webrat is a simpler, effective solution that will let you
run your tests much faster and more frequently.

Initial development was sponsored by [EastMedia](http://www.eastmedia.com).

Synopsis
--------

    def test_sign_up
      visits "/"
      clicks_link "Sign up"
      fills_in "Email", :with => "good@example.com"
      selects "Free account"
      clicks_button "Register"
      ...
    end
  
Behind the scenes, this will perform the following work:

1. Verify that loading the home page is successful
2. Verify that a "Sign up" link exists on the home page
3. Verify that loading the URL pointed to by the "Sign up" link leads to a
   successful page
4. Verify that there is an "Email" input field on the Sign Up page
5. Verify that there is an select field on the Sign Up page with an option for
   "Free account"
6. Verify that there is a "Register" submit button on the page
7. Verify that submitting the Sign Up form with the values "good@example.com"
   and "Free account" leads to a successful page

Take special note of the things _not_ specified in that test, that might cause
tests to break unnecessarily as your application evolves:

- The input field IDs or names (e.g. "user_email" or "user[email]"), which
  could change if you rename a model
- The ID of the form element (Webrat can do a good job of guessing, even if
  there are multiple forms on the page.)
- The URLs of links followed
- The URL the form submission should be sent to, which could change if you
  adjust your routes or controllers
- The HTTP method for the login request

A test written with Webrat can handle these changes to these without any modifications.

Install
-------

To install the latest release:

    sudo gem install webrat

In your stories/helper.rb:
  
    require "webrat"
  
You could also unpack the gem into vendor/plugins.

Requirements
------------

- Rails >= 1.2.6
- Hpricot >= 0.6
- Rails integration tests in Test::Unit _or_
- RSpec stories (using an RSpec version >= revision 2997)

Authors
-------

- Maintained by [Bryan Helmkamp](mailto:bryan@brynary.com)
- Original code written by [Seth Fitzsimmons](mailto:seth@mojodna.net)
- Many other contributors. See attributions in History.txt

License
-------

Copyright (c) 2007 Bryan Helmkamp, Seth Fitzsimmons.
See MIT-LICENSE.txt in this directory.
