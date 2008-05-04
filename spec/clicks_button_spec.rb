require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "clicks_button" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @page = Webrat::Page.new(@session)
    @session.stubs(:current_page).returns(@page)
    @response = mock
    @session.stubs(:response).returns(@response)
  end
  
  it "should fail if no buttons" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login"></form>
    EOS
    
    lambda { @session.clicks_button }.should raise_error
  end
  
  it "should fail if input is not a submit button" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input type="reset" />
      </form>
    EOS

    lambda { @session.clicks_button }.should raise_error
  end
  
  it "should default to get method" do
    @response.stubs(:body).returns(<<-EOS)
      <form action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect)
    @session.clicks_button
  end
  
  it "should assert valid response" do
    @response.stubs(:body).returns(<<-EOS)
      <form action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:assert_response).with(:success)
    @session.clicks_button
  end
  
  it "should default to current url" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get">
        <input type="submit" />
      </form>
    EOS
    @page.stubs(:url).returns("/current")
    @session.expects(:get_via_redirect).with("/current", {})
    @session.clicks_button
  end
  
  it "should submit the first form by default" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/form1">
        <input type="submit" />
      </form>
      <form method="get" action="/form2">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/form1", {})
    @session.clicks_button
  end
  
  it "should not explode on file fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/form1">
        <input type="file" />
        <input type="submit" />
      </form>
    EOS
    @session.clicks_button
  end
  
  it "should submit the form with the specified button" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/form1">
        <input type="submit" />
      </form>
      <form method="get" action="/form2">
        <input type="submit" value="Form2" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/form2", {})
    @session.clicks_button "Form2"
  end
  
  it "should use action from form" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", {})
    @session.clicks_button
  end
  
  it "should use method from form" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect)
    @session.clicks_button
  end
  
  it "should send button as param if it has a name" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" name="login" value="Login" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "login" => "Login")
    @session.clicks_button("Login")
  end
  
  it "should not send button as param if it has no name" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" value="Login" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", {})
    @session.clicks_button("Login")
  end

  it "should send default password field values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_password" name="user[password]" value="mypass" type="password" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"password" => "mypass"})
    @session.clicks_button
  end  
  
  it "should send default hidden field values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="hidden" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => "test@example.com"})
    @session.clicks_button
  end
  
  it "should send default text field values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => "test@example.com"})
    @session.clicks_button
  end
  
  it "should send default checked fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" checked="checked" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "1"})
    @session.clicks_button
  end
  
  it "should send default radio options" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" checked="checked" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"gender" => "F"})
    @session.clicks_button
  end
  
  it "should send correct data for rails style unchecked fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" />
        <input name="user[tos]" type="hidden" value="0" /> TOS
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "0"})
    @session.clicks_button
  end
  
  it "should send correct data for rails style checked fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        <input name="user[tos]" type="hidden" value="0" /> TOS
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "1"})
    @session.clicks_button
  end

  it "should send default collection fields" do
    @response.stubs(:body).returns(<<-EOS)
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
    EOS
    @session.expects(:post_via_redirect).with("/login",
      "options"  => ["burger", "fries", "soda", "soda", "dessert"],
      "response" => { "choices" => [{"selected" => "one"}, {"selected" => "two"}, {"selected" => "two"}]})
    @session.clicks_button
  end
  
  it "should not send default unchecked fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", {})
    @session.clicks_button
  end
  
  it "should send default textarea values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/posts">
        <textarea name="post[body]">Post body here!</textarea>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/posts", "post" => {"body" => "Post body here!"})
    @session.clicks_button
  end
  
  it "should send default selected option value from select" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month">
          <option value="1">January</option>
          <option value="2" selected="selected">February</option>
        </select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "month" => "2")
    @session.clicks_button
  end

  it "should send default selected option inner html from select when no value attribute" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month">
          <option>January</option>
          <option selected="selected">February</option>
        </select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "month" => "February")
    @session.clicks_button
  end
  
  it "should send first select option value when no option selected" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month">
          <option value="1">January</option>
          <option value="2">February</option>
        </select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "month" => "1")
    @session.clicks_button
  end
  
  it "should handle nested properties" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="text" id="contestant_scores_12" name="contestant[scores][1]" value="2"/>
        <input type="text" id="contestant_scores_13" name="contestant[scores][3]" value="4"/>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "contestant" => {"scores" => {'1' => '2', '3' => '4'}})
    @session.clicks_button
  end

  it "should send default empty text field values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => ""})
    @session.clicks_button
  end

  it "should recognize button tags" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <button type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => ""})
    @session.clicks_button
  end

  it "should recognize button tags by content" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <button type="submit">Login</button>
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => ""})
    @session.clicks_button "Login"
  end
end
