require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "select_date" do
  it "should send the values for each individual date component" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_date">Date</label><br />
        <select id="appointment_date_1i" name="appointment[date(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_2i" name="appointment[date(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_3i" name="appointment[date(3i)]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    select_date "December 25, 2003", :from => "Date"
    click_button
  end

  it "should accept a date object" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_date">date</label><br />
        <select id="appointment_date_1i" name="appointment[date(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_2i" name="appointment[date(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_3i" name="appointment[date(3i)]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    select_date Date.parse("December 25, 2003"), :from => "date"
    click_button
  end

  it "should work when no label is specified" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <select id="appointment_date_1i" name="appointment[date(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_2i" name="appointment[date(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_3i" name="appointment[date(3i)]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    select_date "December 25, 2003"
    click_button
  end

  it "should work when the label ends in a non word character" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_date">date ?</label><br />
        <select id="appointment_date_1i" name="appointment[date(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_2i" name="appointment[date(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_3i" name="appointment[date(3i)]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
      webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    select_date Date.parse("December 25, 2003"), :from => "date ?"
    click_button
  end

  it "should fail if the specified label is not found" do
    with_html <<-HTML
      <html>
      <form method="post" action="/appointments">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
      </html>
    HTML

    lambda { select_date "December 25, 2003", :from => "date" }.should raise_error(Webrat::NotFoundError)
  end

end
