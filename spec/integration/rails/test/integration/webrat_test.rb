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

end
