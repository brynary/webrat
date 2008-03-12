require File.dirname(__FILE__) + "/helper"

class SelectsTest < Test::Unit::TestCase
  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  def test_should_fail_if_option_not_found
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS
    @session.expects(:flunk)
    @session.selects "February"
  end
  
  def test_should_fail_if_option_not_found_in_list_specified_by_element_name
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
    EOS
    @session.expects(:flunk)
    @session.selects "February", :from => "year"
  end
  
  def test_should_fail_if_specified_list_not_found
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS
    @session.expects(:flunk)
    @session.selects "February", :from => "year"
  end
  
  def test_should_send_value_from_option
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "month" => "1")
    @session.selects "January"
    @session.clicks_button
  end
  
  def test_should_send_value_from_option_in_list_specified_by_name
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="start_month"><option value="s1">January</option></select>
        <select name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "start_month" => "s1", "end_month" => "e1")
    @session.selects "January", :from => "end_month"
    @session.clicks_button
  end
  
  def test_should_send_value_from_option_in_list_specified_by_label
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "start_month" => "s1", "end_month" => "e1")
    @session.selects "January", :from => "End Month"
    @session.clicks_button
  end
  
  def test_should_use_option_text_if_no_value
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "month" => "January")
    @session.selects "January"
    @session.clicks_button
  end
end
