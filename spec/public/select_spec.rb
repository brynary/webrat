require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "select" do
  it "should fail with a helpful message when option not found" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
      </html>
    HTML

    lambda { select "February", :from => "month" }.should raise_error(Webrat::NotFoundError,
      "The 'February' option was not found in the \"month\" select box")
  end

  it "should fail if option not found in list specified by element name" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
        <select name="year"><option value="2008">2008</option></select>
      </form>
      </html>
    HTML

    lambda { select "February", :from => "year" }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if specified list not found" do
    with_html <<-HTML
      <html>
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
      </html>
    HTML

    lambda { select "February", :from => "year" }.should raise_error(Webrat::NotFoundError)
  end


  it "should fail if the select is disabled" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month" disabled="disabled"><option value="1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda { select "January", :from => "month" }.should raise_error(Webrat::DisabledFieldError)
  end

  it "should send value from option" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "1")
    select "January", :from => "month"
    click_button
  end

  it "should send values with HTML encoded ampersands" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="encoded"><option value="A &amp; B">Encoded</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "encoded" => "A & B")
    select "Encoded", :from => "encoded"
    click_button
  end

  it "should work with empty select lists" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", 'month' => '')
    click_button
  end

  it "should work without specifying the field name or label" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option value="1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "1")
    select "January"
    click_button
  end

  it "should send value from option in list specified by name" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="start_month"><option value="s1">January</option></select>
        <select name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    select "January", :from => "end_month"
    click_button
  end

  it "should send value from option in list specified by label" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    select "January", :from => "End Month"
    click_button
  end

  it "should use option text if no value" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "January")
    select "January", :from => "month"
    click_button
  end

  it "should find option by regexp" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "month" => "January")
    select /jan/i
    click_button
  end

  it "should find options by regexp with HTML entities" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>Peanut butter &amp; jelly</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "month" => "Peanut butter & jelly")
    select /Peanut butter & jelly/
    click_button
  end

  it "should not find options by regexp with HTML entities in the regexp" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>Peanut butter &amp; jelly</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda {
      select /Peanut butter &amp; jelly/
    }.should raise_error(Webrat::NotFoundError)
  end

  it "should fail if no option matching the regexp exists" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda {
      select /feb/i
    }.should raise_error(Webrat::NotFoundError)
  end

  it "should find option by regexp in list specified by label" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <label for="start_month">Start Month</label>
        <select id="start_month" name="start_month"><option value="s1">January</option></select>
        <label for="end_month">End Month</label>
        <select id="end_month" name="end_month"><option value="e1">January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/login", "start_month" => "s1", "end_month" => "e1")
    select /jan/i, :from => "End Month"
    click_button
  end

  it "should properly handle submitting HTML entities in select values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>Peanut butter &amp; jelly</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "month" => "Peanut butter & jelly")
    click_button
  end

  it "should properly handle locating with HTML entities in select values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>Peanut butter &amp; jelly</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "month" => "Peanut butter & jelly")
    select "Peanut butter & jelly"
    click_button
  end

  it "should not locate based on HTML entities" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="month"><option>Peanut butter &amp; jelly</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda {
      select "Peanut butter &amp; jelly"
    }.should raise_error(Webrat::NotFoundError)
  end

  it "should submit duplicates selected options as a single value" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes"><option value="pants" selected="selected">pants</option><option value="pants" selected="selected">pants</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => "pants")
    click_button
  end

  it "should allow fields to be unselected" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes">
          <option value="tshirt" selected="selected">tshirt</option>
          <option value="pants">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", {"clothes"=>""})
    unselect "tshirt"
    click_button
  end

  #
  # Mutliple Selection Fields
  #

  it "should not submit any values for multiples without any selected" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="tshirt">tshirt</option>
          <option value="pants">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", {})
    click_button
  end

  it "should submit with preselected values" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="tshirt" selected="selected">tshirt</option>
          <option value="pants" selected="selected">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['tshirt', 'pants'])
    click_button
  end

  it "should allow selection of multiple fields" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="tshirt">tshirt</option>
          <option value="pants">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['pants'])
    select 'pants'
    click_button
  end

  it "should not overwrite preselected multiples" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="tshirt" selected="selected">tshirt</option>
          <option value="pants">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['tshirt', 'pants'])
    select 'pants'
    click_button
  end

  it "should allow fields that exist to be selected or throw errors" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="top" selected="selected">shirt</option>
          <option value="pants">trousers</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda { select "shirt" }.should_not raise_error(Webrat::NotFoundError)
    lambda { select "trousers" }.should_not raise_error(Webrat::NotFoundError)
    lambda { select "shoes" }.should raise_error(Webrat::NotFoundError)
  end

  it "should allow selected fields to be unselected" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option value="tshirt" selected="selected">tshirt</option>
          <option value="pants" selected="selected">pants</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['pants'])
    unselect 'tshirt'
    click_button
  end

  it "should be able to select options with special characters" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option>tshirt &amp; sweater</option>
          <option>pants &amp; socks</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['pants & socks'])
    select 'pants & socks'
    click_button
  end

  it "should be able to unselect options with special characters" do
    with_html <<-HTML
      <html>
      <form method="post" action="/login">
        <select name="clothes[]" multiple="multiple">
          <option selected="selected">tshirt &amp; sweater</option>
          <option selected="selected">pants &amp; socks</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML

    webrat_session.should_receive(:post).with("/login", "clothes" => ['tshirt & sweater'])
    unselect 'pants & socks'
    click_button
  end

end
