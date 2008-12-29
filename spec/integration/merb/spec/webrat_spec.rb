require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "Webrat" do
  it "should visit pages" do
    response = visit "/"
    response.should contain("Webrat Form")
  end
  
  it "should submit forms" do
    visit "/"
    fill_in "Text field", :with => "Hello"
    check "TOS"
    select "January"
    click_button "Test"
  end
  
end