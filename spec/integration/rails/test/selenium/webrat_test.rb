require 'test_helper'

class WebratTest < ActionController::IntegrationTest
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

  test "should follow internal redirects" do
    visit internal_redirect_path
    assert response_body.include?("OK")
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
end
