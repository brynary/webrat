require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "submit_form" do
  it "should submit forms by ID" do
    with_html <<-HTML
      <html>
        <form id="form1" action="/form1">
          <label for="email">Email:</label> <input type="text" id="email" name="email" /></label>
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form1", "email" => "test@example.com")

    fill_in "Email", :with => "test@example.com"
    submit_form "form1"
  end

  it "should submit forms by CSS" do
    with_html <<-HTML
      <html>
        <form id="form1" action="/form1">
          <label for="email">Email:</label> <input id="email" type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form1", "email" => "test@example.com")

    fill_in "Email", :with => "test@example.com"
    submit_form "form[action='/form1']"
  end

  it "should give priority to selecting forms by ID" do
    with_html <<-HTML
      <html>
        <form action="/form1">
          <label for="email">Email:</label> <input id="email" type="text" name="email" />
          <input type="submit" value="Add" />
        </form>

        <form action="/form2" id="form">
          <label for="email2">Another email:</label> <input id="email2" type="text" name="email" />
          <input type="submit" value="Add" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/form2", "email" => "test@example.com")

    fill_in "Another email", :with => "test@example.com"
    submit_form "form"
  end
end
