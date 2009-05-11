require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "choose" do
  it "should fail if no radio buttons found" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
      </form>
      </html>
    HTML

    lambda { choose "first option" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if input is not a radio button" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="text" name="first_option" />
      </form>
      </html>
    HTML

    lambda { choose "first_option" }.should raise_error(Webrat::NotFoundError)
  end

  it "should check rails style radio buttons" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"gender" => "M"})
    choose "Male"
    click_button
  end

  it "should only submit last chosen value" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/login", "user" => {"gender" => "M"})
    choose "Female"
    choose "Male"
    click_button
  end

  it "should fail if the radio button is disabled" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="radio" name="first_option" disabled="disabled" />
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda { choose "first_option" }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should result in the value on being posted if not specified" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="radio" name="first_option" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "first_option" => "on")
    choose "first_option"
    click_button
  end

  it "should result in the value on being posted if not specified and checked by default" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input type="radio" name="first_option" checked="checked"/>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "first_option" => "on")
    click_button
  end

  it "should result in the value of the selected radio button being posted when a subsequent one is checked by default" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" checked="checked" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "user" => {"gender" => "M"})
    choose "Male"
    click_button
  end
end
