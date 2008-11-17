require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "selects_datetime" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should send the values for each individual date and time components" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    @session.selects_datetime "December 25, 2003 9:30", :from => "Time"
    @session.click_button
  end
  
  it "should accept a time object" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    @session.select_datetime Time.parse("December 25, 2003 9:30"), :from => "Time"
    @session.click_button
  end

  it "should work when no label is specified" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"time(1i)" => '2003', "time(2i)" => "12", "time(3i)" => "25", "time(4i)" => "09", "time(5i)" => "30"})
    @session.selects_datetime "December 25, 2003 9:30"
    @session.click_button
  end

  it "should fail if the specified label is not found" do
    @session.response_body = <<-EOS
      <form method="post" action="/appointments">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    
    lambda { @session.selects_datetime "December 25, 2003 9:30", :from => "Time" }.should raise_error
  end

end
