require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "selects" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should fail if option not found" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS
    
    lambda { @session.selects "February", :from => "month" }.should raise_error
  end
  
  it "should fail if option not found in list specified by element name" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end
  
  it "should fail if specified list not found" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS

    lambda { @session.selects "February", :from => "year" }.should raise_error
  end

  
  it "should fail if the select is disabled" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month" disabled="disabled"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    EOS

    lambda { @session.selects "January", :from => "month" }.should raise_error
  end
  
  it "should send value from option" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "month" => "1")
    @session.selects "January", :from => "month"
    @session.clicks_button
  end

  it "should send values with HTML encoded ampersands" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="encoded"><option value="A &amp; B">Encoded</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "encoded" => "A & B")
    @session.selects "Encoded", :from => "encoded"
    @session.clicks_button
  end

  it "should work with empty select lists" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", 'month' => '')
    @session.clicks_button
  end
  
  it "should work without specifying the field name or label" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "month" => "1")
    @session.selects "January"
    @session.clicks_button
  end
  
  it "should send value from option in list specified by name" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="start_month"><option value="s1">January</option></select>
        <select name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    @session.selects "January", :from => "end_month"
    @session.clicks_button
  end
  
  it "should send value from option in list specified by label" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    @session.selects "January", :from => "End Month"
    @session.clicks_button
  end
  
  it "should use option text if no value" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "month" => "January")
    @session.selects "January", :from => "month"
    @session.clicks_button
  end

  it "should find option by regexp" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "month" => "January")
    @session.selects(/jan/i)
    @session.clicks_button
  end
  
  it "should fail if no option matching the regexp exists" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    
    lambda {
      @session.selects(/feb/i)
    }.should raise_error
  end

  it "should find option by regexp in list specified by label" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    @session.selects(/jan/i, :from => "End Month")
    @session.clicks_button
  end
end
