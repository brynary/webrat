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

  it "should follow internal redirects" do
    response = visit "/internal_redirect"
    response.status.should == 200
    response.should contain("Webrat Form")
  end

  it "should check the value of a field" do
    visit "/"
    field_labeled("Prefilled").value.should == "text"
  end

  it "should not follow external redirects" do
    response = visit "/external_redirect"
    response.status.should == 302
  end

  it "should upload files" do
    visit "/upload"
    attach_file "File", __FILE__
    response = click_button "Upload"
    response.should contain(%(["webrat_spec.rb", "Tempfile"]))
  end
end
