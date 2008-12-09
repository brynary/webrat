require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "within" do
  it "should work when nested" do
    with_html <<-HTML
      <html>
      <div>
        <a href="/page1">Link</a>
      </div>
      <div id="container">
        <div><a href="/page2">Link</a></div>
      </div>
      </html>
    HTML
    
    webrat_session.should_receive(:get).with("/page2", {})
    within "#container" do
      within "div" do
        click_link "Link"
      end
    end
  end
  
  it "should click links within a scope" do
    with_html <<-HTML
      <html>
      <a href="/page1">Link</a>
      <div id="container">
        <a href="/page2">Link</a>
      </div>
      </html>
    HTML
    
    webrat_session.should_receive(:get).with("/page2", {})
    within "#container" do
      click_link "Link"
    end
  end
  
  it "should submit forms within a scope" do
    with_html <<-HTML
      <html>
        <form id="form1" action="/form1">
          <label>Email: <input type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
        <form id="form2" action="/form2">
          <label>Email: <input type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML
    
    webrat_session.should_receive(:get).with("/form2", "email" => "test@example.com")
    within "#form2" do
      fill_in "Email", :with => "test@example.com"
      click_button
    end
  end
  
  it "should not find buttons outside of the scope" do
    with_html <<-HTML
      <html>
      <form action="/form1">
        <input type="submit" value="Add" />
      </form>
      <form id="form2" action="/form2">
      </form>
      </html>
    HTML
    
    within "#form2" do
      lambda {
        click_button
      }.should raise_error(Webrat::NotFoundError)
    end
  end
end
