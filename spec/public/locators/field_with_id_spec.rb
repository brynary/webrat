require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")


describe "field_with_id" do
  it "should work when there is a single quote in the ID" do
    with_html <<-HTML
      <html>
        <form>
        <input type="text" id="user's name">
        </form>
      </html>
    HTML

    field_with_id("user's name").id.should == "user's name"
  end
end
