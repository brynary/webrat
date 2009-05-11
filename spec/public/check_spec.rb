require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "check" do
  it "should fail if no checkbox found" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
        </form>
      </html>
    HTML

    lambda { check "remember_me" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if input is not a checkbox" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="text" name="remember_me" />
        </form>
      </html>
    HTML

    lambda { check "remember_me" }.should raise_error(Webrat::NotFoundError)
  end

  it "should check rails style checkboxes" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "1"})
    check "TOS"
    click_button
  end

  it "should result in the value on being posted if not specified" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" />
          <input type="submit" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "remember_me" => "on")
    check "remember_me"
    click_button
  end

  it "should fail if the checkbox is disabled" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" disabled="disabled" />
          <input type="submit" />
        </form>
      </html>
    HTML

    lambda { check "remember_me" }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should result in a custom value being posted" do
    with_html <<-HTML
      <html>
        <form method="post" action="/login">
          <input type="checkbox" name="remember_me" value="yes" />
          <input type="submit" />
        </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "remember_me" => "yes")
    check "remember_me"
    click_button
  end
end

describe "uncheck" do
  it "should fail if no checkbox found" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
      </form>
      </html>
    HTML

    lambda { uncheck "remember_me" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if input is not a checkbox" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="text" name="remember_me" />
      </form>
      </html>
    HTML

    lambda { uncheck "remember_me" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if the checkbox is disabled" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" checked="checked" disabled="disabled" />
        <input type="submit" />
      </form>
      </html>
    HTML
    lambda { uncheck "remember_me" }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should uncheck rails style checkboxes" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "0"})
    check "TOS"
    uncheck "TOS"
    click_button
  end

  it "should result in value not being posted" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" value="yes" checked="checked" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", {})
    uncheck "remember_me"
    click_button
  end

  it "should work with checkboxes with the same name" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="option_1" name="options[]" type="checkbox" value="1" />
        <label for="option_1">Option 1</label>
        <input id="option_2" name="options[]" type="checkbox" value="2" />
        <label for="option_2">Option 2</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", {"options" => ["1", "2"]})
    check 'Option 1'
    check 'Option 2'
    click_button
  end

  it "should uncheck rails style checkboxes nested inside a label" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <label>
          TOS
          <input name="user[tos]" type="hidden" value="0" />
          <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        </label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "0"})
    uncheck "TOS"
    click_button
  end

end
