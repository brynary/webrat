require File.dirname(__FILE__) + "/test_helper"

class WebratTest < Test::Unit::TestCase
  def test_visits_pages
    visit "/"
    assert response_body.include?("visit")

    click_link "there"
    assert response_body.include?('<form method="post" action="/go">')
  end
  
  def test_submits_form
    visit "/go"
    fill_in "Name", :with => "World"
    click_button "Submit"
    
    assert response_body.include?("Hello, World")
  end
  
  def test_follows_redirects
    visit "/redirect"
    assert response_body.include?("visit")
  end
end
