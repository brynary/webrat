require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "selects" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  it "should fail if option not found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS
    
    lambda { @session.selects "February", :from => "month" }.should raise_error
  end
  
  it "should fail if option not found in list specified by element name" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end
  
  it "should fail if specified list not found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end
  
  it "should send value from option" do
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

  it "should work with empty select lists" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <select name="month"></select>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", 'month' => '')
    @session.clicks_button
  end
  
  it "should work without specifying the field name or label" do
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
  
  it "should send value from option in list specified by name" do
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
  
  it "should send value from option in list specified by label" do
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
  
  it "should use option text if no value" do
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

  it "should find option by regexp" do
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

  it "should find option by regexp in list specified by label" do
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
