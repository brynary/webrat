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

  it "should work when the scope is inside the form" do
    with_html <<-HTML
      <html>
        <form id="form2" action="/form2">
          <div class="important">
            <label>Email: <input type="text" class="email2" name="email" /></label>
          </div>
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form2", "email" => "test@example.com")
    within ".important" do
      fill_in "Email", :with => "test@example.com"
    end

    submit_form "form2"
  end

  it "should work when the form submission occurs inside a scope" do
    with_html <<-HTML
      <html>
        <body>
          <div>
            <form id="form2" action="/form2">
              <label for="email">Email</label><input id="email" type="text" class="email2" name="email" />
              <input type="submit" value="Add" />
            </form>
          </div>
        </body>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form2", "email" => "test@example.com")
    within "form[@action='/form2']" do
      fill_in "Email", :with => "test@example.com"
      click_button "Add"
    end
  end

  it "should work when there are multiple forms with the same label text" do
    with_html <<-HTML
      <html>
        <body>
          <div>
            <form id="form1" action="/form1">
              <label for="email1">Email</label><input id="email1" type="text" class="email1" name="email1" />
              <input type="submit" value="Add" />
            </form>
            <form id="form2" action="/form2">
              <label for="email2">Email</label><input id="email2" type="text" class="email2" name="email2" />
              <input type="submit" value="Add" />
            </form>
          </div>
        </body>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form2", "email2" => "test@example.com")
    within "form[@action='/form2']" do
      fill_in "Email", :with => "test@example.com"
      click_button "Add"
    end
  end

  it "should not find fields outside of the scope" do
    with_html <<-HTML
      <html>
        <form id="form1" action="/form1">
          <label for="email">Email</label><input id="email" type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
        <form id="form2" action="/form2">
          <label for="email">Email</label><input id="email" type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form2", "email" => "test@example.com")
    within "#form2" do
      fill_in "Email", :with => "test@example.com"
      click_button "Add"
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

  it "should raise a Webrat::NotFounderror error when the scope doesn't exist" do
    with_html <<-HTML
      <html>
      </html>
    HTML

    lambda {
      within "#form2" do
      end
    }.should raise_error(Webrat::NotFoundError)
  end
end
