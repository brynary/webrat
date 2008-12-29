require 'test_helper'

class WebratTest < ActionController::IntegrationTest
  test "should visit pages" do
    visit root_path
    assert_tag "Webrat Form"
    assert response.body.include?("Webrat Form")
  end
  
  test "should submit forms" do
    visit root_path
    fill_in "Text field", :with => "Hello"
    check "TOS"
    select "January"
    click_button "Test"
  end
end
