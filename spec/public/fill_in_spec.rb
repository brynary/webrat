require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "fill_in" do
  it "should work with textareas" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_text">User Text</label>
        <textarea id="user_text" name="user[text]"></textarea>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"text" => "filling text area"})
    fill_in "User Text", :with => "filling text area"
    click_button
  end
  
  it "should support multiline values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_text">User Text</label>
        <textarea id="user_text" name="user[text]"></textarea>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"text" => "One\nTwo"})
    fill_in "User Text", :with => "One\nTwo"
    click_button
  end

  it "should work with password fields" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="user_text" name="user[text]" type="password" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"text" => "pass"})
    fill_in "user_text", :with => "pass"
    click_button
  end

  it "should fail if input not found" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
      </form>
      </html>
    HTML

    lambda { fill_in "Email", :with => "foo@example.com" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if input is disabled" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" type="text" disabled="disabled" />
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda { fill_in "Email", :with => "foo@example.com" }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should allow overriding default form values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    fill_in "user[email]", :with => "foo@example.com"
    click_button
  end

  it "should choose the shortest label match" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_mail1">Some other mail</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "user" => {"mail1" => "", "mail2" => "value"})
    fill_in "Some", :with => "value"
    click_button
  end

  it "should choose the first label match if closest is a tie" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_mail1">Some mail one</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail two</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "user" => {"mail1" => "value", "mail2" => ""})
    fill_in "Some mail", :with => "value"
    click_button
  end

  it "should anchor label matches to start of label" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_email">Some mail</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
      </html>
    HTML

    lambda { fill_in "mail", :with => "value" }.should raise_error(Webrat::NotFoundError)
  end

  it "should anchor label matches to word boundaries" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_email">Emailtastic</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
      </html>
    HTML

    lambda { fill_in "Email", :with => "value" }.should raise_error(Webrat::NotFoundError)
  end

  it "should work with inputs nested in labels" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label>
          Email
          <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        </label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    fill_in "Email", :with => "foo@example.com"
    click_button
  end

  it "should work with full input names" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    fill_in "user[email]", :with => "foo@example.com"
    click_button
  end

  it "should work if the input type is not set" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="user_email" name="user[email]"  />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    fill_in "user[email]", :with => "foo@example.com"
    click_button
  end

  it "should work with symbols" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    fill_in :email, :with => "foo@example.com"
    click_button
  end

  it "should escape field values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/users">
        <label for="user_phone">Phone</label>
        <input id="user_phone" name="user[phone]" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/users", "user" => {"phone" => "+1 22 33"})
    fill_in 'Phone', :with => "+1 22 33"
    click_button
  end
end
