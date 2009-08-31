require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "click_button" do
  it "should fail if no buttons" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login"></form>
      </html>
    HTML

    lambda { click_button }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if input is not a submit button" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input type="reset" />
      </form>
      </html>
    HTML

    lambda { click_button }.should raise_error(Webrat::NotFoundError)
  end


  it "should fail if button is disabled" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input type="submit" disabled="disabled" />
      </form>
      </html>
    HTML

    lambda { click_button }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should default to get method" do
    with_html <<-HTML
      <html>
      <form action="/login">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get)
    click_button
  end

  it "should assert valid response" do
    with_html <<-HTML
      <html>
      <form action="/login">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.response_code = 501
    lambda { click_button }.should raise_error(Webrat::PageLoadError)
  end

  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      with_html <<-HTML
        <html>
        <form action="/login">
          <input type="submit" />
        </form>
        </html>
      HTML
      webrat_session.stub!(:redirect? => false)
      webrat_session.response_code = status
      lambda { click_button }.should_not raise_error
    end
  end

  it "should submit the first form by default" do
    with_html <<-HTML
      <html>
      <form method="get" action="/form1">
        <input type="submit" />
      </form>
      <form method="get" action="/form2">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/form1", {})
    click_button
  end

  it "should not explode on file fields" do
    with_html <<-HTML
      <html>
      <form method="get" action="/form1">
        <input type="file" />
        <input type="submit" />
      </form>
      </html>
    HTML
    click_button
  end

  it "should submit the form with the specified button" do
    with_html <<-HTML
      <html>
        <form method="get" action="/form1">
          <input type="submit" />
        </form>
        <form method="get" action="/form2">
          <input type="submit" value="Form2" />
        </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/form2", {})
    click_button "Form2"
  end

  it "should use action from form" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", {})
    click_button
  end

  it "should use method from form" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post)
    click_button
  end

  it "should send button as param if it has a name" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" name="login" value="Login" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "login" => "Login")
    click_button("Login")
  end

  it "should not send button as param if it has no name" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" value="Login" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", {})
    click_button("Login")
  end

  it "should send default password field values" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_password" name="user[password]" value="mypass" type="password" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"password" => "mypass"})
    click_button
  end

  it "should send default hidden field values" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="hidden" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"email" => "test@example.com"})
    click_button
  end

  it "should send default text field values" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"email" => "test@example.com"})
    click_button
  end

  it "should not send disabled field values" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input disabled="disabled" id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input disabled="disabled" id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input disabled="disabled" id="user_gender_female" name="user[gender]" type="radio" value="F" checked="checked" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", {})
    click_button
  end

  it "should send default checked fields" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" checked="checked" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "1"})
    click_button
  end

  it "should send default radio options" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" checked="checked" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"gender" => "F"})
    click_button
  end

  it "should send correct data for rails style unchecked fields" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" />
        <input name="user[tos]" type="hidden" value="0" /> TOS
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "0"})
    click_button
  end

  it "should send correct data for rails style checked fields" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        <input name="user[tos]" type="hidden" value="0" /> TOS
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"tos" => "1"})
    click_button
  end

  it "should send default collection fields" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="checkbox" name="options[]" value="burger" checked="checked" />
        <input type="radio" name="options[]" value="fries" checked="checked" />
        <input type="text" name="options[]" value="soda" />
        <!-- Same value appearing twice -->
        <input type="text" name="options[]" value="soda" />
        <input type="hidden" name="options[]" value="dessert" />
        <input type="hidden" name="response[choices][][selected]" value="one" />
        <input type="hidden" name="response[choices][][selected]" value="two" />
        <!-- Same value appearing twice -->
        <input type="hidden" name="response[choices][][selected]" value="two" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login",
      "options"  => ["burger", "fries", "soda", "soda", "dessert"],
      "response" => { "choices" => [{"selected" => "one"}, {"selected" => "two"}, {"selected" => "two"}]})
    click_button
  end

  it "should not send default unchecked fields" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", {})
    click_button
  end

  it "should send default textarea values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/posts">
        <textarea name="post[body]">Post body here!</textarea>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/posts", "post" => {"body" => "Post body here!"})
    click_button
  end

  it "should properly handle HTML entities in textarea default values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/posts">
        <textarea name="post[body]">Peanut butter &amp; jelly</textarea>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/posts", "post" => {"body" => "Peanut butter & jelly"})
    click_button
  end

  it "should send default selected option value from select" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month">
          <option value="1">January</option>
          <option value="2" selected="selected">February</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "month" => "2")
    click_button
  end

  it "should send default selected option inner html from select when no value attribute" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month">
          <option>January</option>
          <option selected="selected">February</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "month" => "February")
    click_button
  end

  it "should send first select option value when no option selected" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month">
          <option value="1">January</option>
          <option value="2">February</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "month" => "1")
    click_button
  end

  it "should handle nested properties" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="text" id="contestant_scores_12" name="contestant[scores][1]" value="2"/>
        <input type="text" id="contestant_scores_13" name="contestant[scores][3]" value="4"/>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "contestant" => {"scores" => {'1' => '2', '3' => '4'}})
    click_button
  end

  it "should send default empty text field values" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"email" => ""})
    click_button
  end

  it "should recognize button tags" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <button type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"email" => ""})
    click_button
  end

  it "should recognize input tags with the type button" do
    with_html <<-HTML
      <html>
      <form action="/">
        <input type="button" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get)
    click_button
  end

  it "should recognize image button tags" do
    with_html <<-HTML
      <html>
      <form action="/">
        <input type="image" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get)
    click_button
  end

  it "should find buttons by their IDs" do
    with_html <<-HTML
      <html>
      <form action="/">
        <input type="submit" id="my_button" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get)
    click_button "my_button"
  end

  it "should find image buttons by their alt text" do
    with_html <<-HTML
      <html>
      <form action="/">
        <input type="image" alt="Go" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get)
    click_button "Go"
  end

  it "should recognize button tags by content" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <button type="submit">Login</button>
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"email" => ""})
    click_button "Login"
  end
end
