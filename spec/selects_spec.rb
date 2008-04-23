require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "selects" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  it "should_fail_if_option_not_found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS
    
    lambda { @session.selects "February", :from => "month" }.should raise_error
  end
  
  it "should_fail_if_option_not_found_in_list_specified_by_element_name" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end
  
  it "should_fail_if_specified_list_not_found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end
  
  it "should_send_value_from_option" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "month" => "1")
    @session.selects "January", :from => "month"
    @session.clicks_button
  end

  it "should_work_with_empty_select_lists" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", 'month' => '')
    @session.clicks_button
  end
  
  it "should_work_without_specifying_the_field_name_or_label" do
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
  
  it "should_send_value_from_option_in_list_specified_by_name" do
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
  
  it "should_send_value_from_option_in_list_specified_by_label" do
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
  
  it "should_use_option_text_if_no_value" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "month" => "January")
    @session.selects "January", :from => "month"
    @session.clicks_button
  end

  it "should_find_option_by_regexp" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "month" => "January")
    @session.selects(/jan/i)
    @session.clicks_button
  end

  it "should_find_option_by_regexp_in_list_specified_by_label" do
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
    @session.selects(/jan/i, :from => "End Month")
    @session.clicks_button
  end
end
