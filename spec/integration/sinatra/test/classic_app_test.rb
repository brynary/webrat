require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/../classic_app"

class MyClassicAppTest < Test::Unit::TestCase
  def test_visits_pages
    visit "/"
    assert response_body.include?("visit")

    click_link "there"
    assert response_body.include?('<form method="post" action="/go">')
  end

  def test_submits_form
    visit "/go"
    fill_in "Name", :with => "World"
    fill_in "Email", :with => "world@example.org"
    click_button "Submit"

    assert response_body.include?("Hello, World")
    assert response_body.include?("Your email is: world@example.org")
  end

  def test_check_value_of_field
    visit "/"
    assert field_labeled("Prefilled").value, "text"
  end

  def test_follows_internal_redirects
    visit "/internal_redirect"
    assert response_body.include?("visit")
  end

  def test_does_not_follow_external_redirects
    visit "/external_redirect"
    assert response_code == 302
  end
end
