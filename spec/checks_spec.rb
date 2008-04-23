require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "checks" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  it "should_fail_if_no_checkbox_found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
      </form>
    EOS
    
    lambda { @session.checks "remember_me" }.should raise_error
  end

  it "should_fail_if_input_is_not_a_checkbox" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="text" name="remember_me" />
      </form>
    EOS
    
    lambda { @session.checks "remember_me" }.should raise_error
  end
  
  it "should_check_rails_style_checkboxes" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "1"})
    @session.checks "TOS"
    @session.clicks_button
  end
  
  it "should_result_in_the_value_on_being_posted_if_not_specified" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "remember_me" => "on")
    @session.checks "remember_me"
    @session.clicks_button
  end
  
  it "should_result_in_a_custom_value_being_posted" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" value="yes" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "remember_me" => "yes")
    @session.checks "remember_me"
    @session.clicks_button
  end
end

describe "unchecks" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  it "should_fail_if_no_checkbox_found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
      </form>
    EOS

    lambda { @session.unchecks "remember_me" }.should raise_error
  end

  it "should_fail_if_input_is_not_a_checkbox" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="text" name="remember_me" />
      </form>
    EOS
    
    lambda { @session.unchecks "remember_me" }.should raise_error
  end
  
  it "should_uncheck_rails_style_checkboxes" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_tos" name="user[tos]" type="checkbox" value="1" checked="checked" />
        <input name="user[tos]" type="hidden" value="0" />
        <label for="user_tos">TOS</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"tos" => "0"})
    @session.checks "TOS"
    @session.unchecks "TOS"
    @session.clicks_button
  end

  it "should_result_in_value_not_being_posted" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="checkbox" name="remember_me" value="yes" checked="checked" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", {})
    @session.unchecks "remember_me"
    @session.clicks_button
  end
end