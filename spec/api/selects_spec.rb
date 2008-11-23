require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "selects" do
  it "should fail with a helpful message when option not found" do
    with_html <<-HTML
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    HTML
    
    lambda { selects "February", :from => "month" }.should raise_error(
          Exception, "The 'February' option was not found in the 'month' select box") 
  end
  
  it "should fail if option not found in list specified by element name" do
    with_html <<-HTML
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
    HTML

    lambda { selects "February", :from => "year" }.should raise_error
  end
  
  it "should fail if specified list not found" do
    with_html <<-HTML
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    HTML

    lambda { selects "February", :from => "year" }.should raise_error
  end

  
  it "should fail if the select is disabled" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month" disabled="disabled"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    HTML

    lambda { selects "January", :from => "month" }.should raise_error
  end
  
  it "should send value from option" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "1")
    selects "January", :from => "month"
    click_button
  end

  it "should send values with HTML encoded ampersands" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="encoded"><option value="A &amp; B">Encoded</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "encoded" => "A & B")
    selects "Encoded", :from => "encoded"
    click_button
  end

  it "should work with empty select lists" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", 'month' => '')
    click_button
  end
  
  it "should work without specifying the field name or label" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "1")
    selects "January"
    click_button
  end
  
  it "should send value from option in list specified by name" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="start_month"><option value="s1">January</option></select>
        <select name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    selects "January", :from => "end_month"
    click_button
  end
  
  it "should send value from option in list specified by label" do
    with_html <<-HTML
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    selects "January", :from => "End Month"
    click_button
  end
  
  it "should use option text if no value" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "January")
    selects "January", :from => "month"
    click_button
  end

  it "should find option by regexp" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "January")
    selects(/jan/i)
    click_button
  end
  
  it "should fail if no option matching the regexp exists" do
    with_html <<-HTML
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    HTML
    
    lambda {
      selects(/feb/i)
    }.should raise_error
  end

  it "should find option by regexp in list specified by label" do
    with_html <<-HTML
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    selects(/jan/i, :from => "End Month")
    click_button
  end
end
