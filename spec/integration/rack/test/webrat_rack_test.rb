require "rubygems"
require File.dirname(__FILE__) + "/helper"

class WebratRackTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include Webrat::HaveTagMatcher

  def build_rack_mock_session
    Rack::MockSession.new(app, "www.example.com")
  end

  def test_visits_pages
     visit "/"
     click_link "there"

     assert_have_tag("form[@method='post'][@action='/go']")
  end

  def test_submits_form
    visit "/go"
    fill_in "Name", :with => "World"
    fill_in "Email", :with => "world@example.org"
    click_button "Submit"

    assert_contain "Hello, World"
    assert_contain "Your email is: world@example.org"
  end

  def test_check_value_of_field
    visit "/"
    assert_equal field_labeled("Prefilled").value, "text"
  end

  def test_follows_internal_redirects
    visit "/internal_redirect"
    assert_contain "visit"
  end

  def test_does_not_follow_external_redirects
    visit "/external_redirect"
    assert last_response.redirect?
  end

  def test_absolute_url_redirect
    visit "/absolute_redirect"
    assert_contain "spam"
  end

  def test_upload_file
    visit "/upload"
    attach_file "File", __FILE__, "text/ruby"
    click_button "Upload"

    upload = Marshal.load(response_body)
    assert_equal "text/ruby", upload[:type]
    assert_equal "webrat_rack_test.rb", upload[:filename]
    assert_equal File.read(__FILE__), upload[:tempfile]
  end
end

class WebratRackSetupTest < Test::Unit::TestCase
  def test_usable_without_mixin
    rack_test_session = Rack::Test::Session.new(Rack::MockSession.new(app))
    adapter = Webrat::RackAdapter.new(rack_test_session)
    session = Webrat::Session.new(adapter)

    session.visit "/foo"

    assert_equal "spam", session.response_body
    assert_equal "spam", rack_test_session.last_response.body
  end
end
