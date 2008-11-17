require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "select_time" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should send the values for each individual time component" do
    @session.response_body = <<-EOS
      <form action="/appointments" method="post">
        <label for="appointment_time">Time</label><br />
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
      "appointment" => {"time(4i)" => "09", "time(5i)" => "30"})
    @session.selects_time "9:30AM", :from => "Time"
    @session.click_button
  end
  
  it "should accept a time object" do
    @session.response_body = <<-EOS
      <form action="/appointments" method="post">
        <label for="appointment_time">Time</label><br />
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
      "appointment" => {"time(4i)" => "09", "time(5i)" => "30"})
    @session.select_time Time.parse("9:30AM"), :from => "Time"
    @session.click_button
  end

  it "should work when no label is specified" do
    @session.response_body = <<-EOS
      <form action="/appointments" method="post">
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
      "appointment" => {"time(4i)" => "09", "time(5i)" => "30"})
    @session.select_time "9:30"
    @session.click_button
  end

  it "should fail if the specified label is not found" do
    @session.response_body = <<-EOS
      <form method="post" action="/appointments">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    
    lambda { @session.select_time "9:30", :from => "Time" }.should raise_error
  end

end
