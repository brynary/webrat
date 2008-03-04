require File.dirname(__FILE__) + "/helper"

class FillsInTest < Test::Unit::TestCase
  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end
  
  def test_should_work_with_textareas
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

  def test_should_fail_if_input_not_found
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
      </form>
    EOS
    @session.expects(:flunk)
    @session.fills_in "Email", :with => "foo@example.com"
  end
  
  def test_should_allow_overriding_default_form_values
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
  
  def test_should_choose_the_closest_label_match
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
  
  def test_should_choose_the_first_label_match_if_closest_is_a_tie
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
  
  def test_should_anchor_label_matches_to_start_of_label
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Some mail</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    assert_raises(RuntimeError) { @session.fills_in "mail", :with => "value" }
  end
  
  def test_should_anchor_label_matches_to_word_boundaries
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="user_email">Emailtastic</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    assert_raises(RuntimeError) { @session.fills_in "Email", :with => "value" }
  end
  
  def test_should_work_with_inputs_nested_in_labels
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
  
  def test_should_work_with_full_input_names
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
  
  def test_should_work_with_symbols
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
