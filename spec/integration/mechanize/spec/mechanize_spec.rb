require File.dirname(__FILE__) + "/spec_helper"

describe "Webrat's Mechanize mode" do
  it "should work" do
    response = visit("http://localhost:9292/")
    response.should contain("Hello World")
  end

  it "should follow redirects" do
    response = visit("http://localhost:9292/internal_redirect")
    response.should contain("Redirected")
  end

  it "should follow links"

  it "should submit forms" do
    visit "http://localhost:9292/form"
    fill_in "Email", :with => "albert@example.com"
    response = click_button "Add"

    response.should contain("Welcome albert@example.com")
  end

  it "should not follow external redirects" do
    pending do
      response = visit("http://localhost:9292/external_redirect")
      response.should contain("Foo")
    end
  end
end
