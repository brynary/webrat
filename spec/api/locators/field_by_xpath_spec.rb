require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")


describe "field_by_xpath" do
  it "should work" do
    with_html <<-HTML
      <html>
        <form>
        <label for="element_42">The Label</label>
        <input type="text" id="element_42">
        </form>
      </html>
    HTML
    
    field_by_xpath(".//input").id.should == "element_42"
  end
end
