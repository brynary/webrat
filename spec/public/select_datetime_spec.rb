require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "select_datetime" do
  it "should send the values for each individual date and time components" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_time">Time</label><br />
        <select id="appointment_time_1i" name="appointment[time(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_time_2i" name="appointment[time(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_time_3i" name="appointment[time(3i)]">
          <option value="25">25</option>
        </select>
        <select id="appointment_time_4i" name="appointment[time(4i)]">
          <option value="09">09</option>
        </select>
     : <select id="appointment_time_5i" name="appointment[time(5i)]">
          <option value="30">30</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    select_datetime "December 25, 2003 9:30", :from => "Time"
    click_button
  end

  it "should accept a time object" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_time">Time</label><br />
        <select id="appointment_time_1i" name="appointment[time(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_time_2i" name="appointment[time(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_time_3i" name="appointment[time(3i)]">
          <option value="25">25</option>
        </select>
        <select id="appointment_time_4i" name="appointment[time(4i)]">
          <option value="09">09</option>
        </select>
     : <select id="appointment_time_5i" name="appointment[time(5i)]">
          <option value="30">30</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    select_datetime Time.parse("December 25, 2003 9:30"), :from => "Time"
    click_button
  end

  it "should work when the label ends in a non word character" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <label for="appointment_time">Time ?</label><br />
        <select id="appointment_time_1i" name="appointment[time(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_time_2i" name="appointment[time(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_time_3i" name="appointment[time(3i)]">
          <option value="25">25</option>
        </select>
        <select id="appointment_time_4i" name="appointment[time(4i)]">
          <option value="09">09</option>
        </select>
     : <select id="appointment_time_5i" name="appointment[time(5i)]">
          <option value="30">30</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    select_datetime "December 25, 2003 9:30", :from => "Time ?"
    click_button
  end


  it "should work when no label is specified" do
    with_html <<-HTML
      <html>
      <form action="/appointments" method="post">
        <select id="appointment_time_1i" name="appointment[time(1i)]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_time_2i" name="appointment[time(2i)]">
          <option value="12">December</option>
        </select>
        <select id="appointment_time_3i" name="appointment[time(3i)]">
          <option value="25">25</option>
        </select>
        <select id="appointment_time_4i" name="appointment[time(4i)]">
          <option value="09">09</option>
        </select>
     : <select id="appointment_time_5i" name="appointment[time(5i)]">
          <option value="30">30</option>
        </select>
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/appointments",
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    select_datetime "December 25, 2003 9:30"
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

    lambda { select_datetime "December 25, 2003 9:30", :from => "Time" }.should raise_error(Webrat::NotFoundError)
  end

end
