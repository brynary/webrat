require File.dirname(__FILE__) + "/helper"

class ChoosesTest < Test::Unit::TestCase
  
  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end
  
  def test_should_fail_if_no_radio_buttons_found
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
      </form>
    EOS
    @session.expects(:flunk)
    @session.chooses "first option"
  end
  
  def test_should_fail_if_input_is_not_a_radio_button
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="text" name="first_option" />
      </form>
    EOS
    @session.expects(:flunk)
    @session.chooses "first_option"
  end  
  
  def test_should_check_rails_style_radio_buttons
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"gender" => "M"})
    @session.chooses "Male"
    @session.clicks_button
  end
  
  def test_should_only_submit_last_chosen_value
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"gender" => "M"})
    @session.chooses "Female"
    @session.chooses "Male"
    @session.clicks_button
  end  
  
  def test_should_result_in_the_value_on_being_posted_if_not_specified
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="radio" name="first_option" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "first_option" => "on")
    @session.chooses "first_option"
    @session.clicks_button
  end  
  
end