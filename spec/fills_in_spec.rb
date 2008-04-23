require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "fills_in" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end
  
  it "should_work_with_textareas" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_text">User Text</label>
        <textarea id="user_text" name="user[text]"></textarea>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"text" => "filling text area"})
    @session.fills_in "User Text", :with => "filling text area"
    @session.clicks_button
  end
  
  it "should_work_with_password_fields" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input id="user_text" name="user[text]" type="password" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"text" => "pass"})
    @session.fills_in "user_text", :with => "pass"
    @session.clicks_button
  end

  it "should_fail_if_input_not_found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
      </form>
    EOS
    
    lambda { @session.fills_in "Email", :with => "foo@example.com" }.should raise_error
  end
  
  it "should_allow_overriding_default_form_values" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "user[email]", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should_choose_the_shortest_label_match" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_mail1">Some other mail</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
    EOS
    
    @session.expects(:post_via_redirect).with("/login", "user" => {"mail1" => "", "mail2" => "value"})
    @session.fills_in "Some", :with => "value"
    @session.clicks_button
  end
  
  it "should_choose_the_first_label_match_if_closest_is_a_tie" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_mail1">Some mail one</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail two</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
    EOS
    
    @session.expects(:post_via_redirect).with("/login", "user" => {"mail1" => "value", "mail2" => ""})
    @session.fills_in "Some mail", :with => "value"
    @session.clicks_button
  end
  
  it "should_anchor_label_matches_to_start_of_label" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Some mail</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    lambda { @session.fills_in "mail", :with => "value" }.should raise_error
  end
  
  it "should_anchor_label_matches_to_word_boundaries" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Emailtastic</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    lambda { @session.fills_in "Email", :with => "value" }.should raise_error
  end
  
  it "should_work_with_inputs_nested_in_labels" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label>
          Email
          <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        </label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "Email", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should_work_with_full_input_names" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "user[email]", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should_work_with_symbols" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in :email, :with => "foo@example.com"
    @session.clicks_button
  end
end
