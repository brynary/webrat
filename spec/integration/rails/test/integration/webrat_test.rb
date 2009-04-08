require 'test_helper'

class WebratTest < ActionController::IntegrationTest

  test "should visit fully qualified urls" do
    visit root_url(:host => "chunkybacon.example.com")
    assert_equal "chunkybacon", request.subdomains.first
  end

  test "should visit pages" do
    visit root_path
    assert_contain("Webrat Form")
  end

  test "should submit forms" do
    visit root_path
    fill_in "Text field", :with => "Hello"
    check "TOS"
    select "January"
    click_button "Test"
  end

  test "should check the value of a field" do
    visit "/"
    assert field_labeled("Prefilled").value, "text"
  end

  test "should not carry params through redirects" do
    visit before_redirect_form_path
    fill_in "Text field", :with => "value"
    click_button

    assert response.body !~ /value/
    assert response.body =~ /custom_param/
  end

  test "should follow internal redirects" do
    visit internal_redirect_path
    assert !response.redirect?
    assert response.body.include?("OK")
  end

  test "should not follow external redirects" do
    visit external_redirect_path
    assert response.redirect?
  end

  test "should click link by text" do
    visit internal_redirect_path
    click_link "Test Link Text"
    assert_contain("Webrat Form")
  end

  test "should click link by id" do
    visit internal_redirect_path
    click_link "link_id"
    assert_contain("Webrat Form")
  end

  test "should be able to assert xpath" do
    visit root_path
    assert_have_xpath "//h1"
  end

  test "should be able to assert selector" do
    visit root_path
    assert_have_selector "h1"
  end

  test "should detect infinite redirects" do
    assert_raises Webrat::InfiniteRedirectError do
      visit infinite_redirect_path
    end
  end

#  test "should be able to assert have tag" do
#    visit root_path
#    assert_have_tag "h1"
#  end
end
