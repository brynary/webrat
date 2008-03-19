require File.dirname(__FILE__) + "/helper"

class ClicksButtonTest < Test::Unit::TestCase
  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @response = mock
    @session.stubs(:response).returns(@response)
  end
  
  def test_should_fail_if_no_buttons
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login"></form>
    EOS
    @session.expects(:flunk)
    @session.clicks_button
  end
  
  def test_should_fail_if_input_is_not_a_submit_button
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input type="reset" />
      </form>
    EOS
    @session.expects(:flunk)
    @session.clicks_button
  end
  
  def test_should_default_to_get_method
    @response.stubs(:body).returns(<<-EOS)
      <form action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect)
    @session.clicks_button
  end
  
  def test_should_assert_valid_response
    @response.stubs(:body).returns(<<-EOS)
      <form action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:assert_response).with(:success)
    @session.clicks_button
  end
  
  def test_should_default_to_current_url
    @response.stubs(:body).returns(<<-EOS)
      <form method="get">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:current_url).returns("/current")
    @session.expects(:get_via_redirect).with("/current", {})
    @session.clicks_button
  end
  
  def test_should_submit_the_first_form_by_default
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
  
  def test_should_submit_the_form_with_the_specified_button
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
  
  def test_should_use_action_from_form
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", {})
    @session.clicks_button
  end
  
  def test_should_use_method_from_form
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect)
    @session.clicks_button
  end
  
  def test_should_send_button_as_param_if_it_has_a_name
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" name="login" value="Login" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "login" => "Login")
    @session.clicks_button("Login")
  end
  
  def test_should_not_send_button_as_param_if_it_has_no_name
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="submit" name="cancel" value="Cancel" />
        <input type="submit" value="Login" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", {})
    @session.clicks_button("Login")
  end
  
  def test_should_send_default_hidden_field_values
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="hidden" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => "test@example.com"})
    @session.clicks_button
  end
  
  def test_should_send_default_text_field_values
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => "test@example.com"})
    @session.clicks_button
  end
  
  def test_should_send_default_checked_fields
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" checked="checked" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "1"})
    @session.clicks_button
  end
  
  def test_should_send_default_radio_options
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
  
  def test_should_send_correct_data_for_rails_style_unchecked_fields
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
  
  def test_should_send_correct_data_for_rails_style_checked_fields
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

  def test_should_send_default_collection_fields
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
      "options"  => ["soda", "soda", "dessert", "burger", "fries"],
      "response" => { "choices" => [{"selected" => "one"}, {"selected" => "two"}, {"selected" => "two"}]})
    @session.clicks_button
  end
  
  def test_should_not_send_default_unchecked_fields
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" value="1" type="checkbox" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", {})
    @session.clicks_button
  end
  
  def test_should_send_default_textarea_values
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/posts">
        <textarea name="post[body]">Post body here!</textarea>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/posts", "post" => {"body" => "Post body here!"})
    @session.clicks_button
  end
  
  def test_should_send_default_selected_option_value_from_select
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

  def test_should_send_default_selected_option_inner_html_from_select_when_no_value_attribute
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
  
  def test_should_send_first_select_option_value_when_no_option_selected
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
  
  def test_should_handle_nested_properties
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

  def test_should_send_default_empty_text_field_values
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_email" name="user[email]" value="" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"email" => ""})
    @session.clicks_button
  end
end
