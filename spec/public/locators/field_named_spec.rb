require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "field_named" do
  it "should work when passed a regular expression for the name" do
    with_html <<-HTML
      <html>
        <form>
        <input type="text" name="user_1_input">
        </form>
      </html>
    HTML
    result = field_named(/user_\d_input/).element.attributes['name'].value
    result.should == "user_1_input"
  end
end
