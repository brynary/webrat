require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "selects_date" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should send the values for each individual date component" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    @session.selects_date "December 25, 2003", :from => "Date"
    @session.click_button
  end

  it "should select the date components with the suffix convention provided" do
    @session.response_body = <<-EOS
      <form action="/appointments" method="post">
        <label for="appointment_date">Date</label><br />
        <select id="appointment_date_year" name="appointment[year]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_month" name="appointment[month]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_day" name="appointment[day]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"year" => '2003', "month" => "12", "day" => "25"})
    @session.selects_date "December 25, 2003 9:30", :from => "Date", :suffix_convention => :full_words
    @session.click_button
  end

  it "should select the date components with the suffixes provided" do
    @session.response_body = <<-EOS
      <form action="/appointments" method="post">
        <label for="appointment_date">Date</label><br />
        <select id="appointment_date_y" name="appointment[y]">
          <option value="2003">2003</option>
        </select>
        <select id="appointment_date_mo" name="appointment[mo]">
          <option value="12">December</option>
        </select>
        <select id="appointment_date_d" name="appointment[d]">
          <option value="25">25</option>
        </select>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"y" => '2003', "mo" => "12", "d" => "25"})
    @session.selects_date "December 25, 2003 9:30", :from => "Date", 
                              :suffixes => {:year => 'y', :month => 'mo', :day => 'd'}
    @session.click_button
  end
 
  
  it "should accept a date object" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    @session.selects_date Date.parse("December 25, 2003"), :from => "date"
    @session.click_button
  end

  it "should work when no label is specified" do
    @session.response_body = <<-EOS
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
    EOS
    @session.should_receive(:post).with("/appointments", 
      "appointment" => {"date(1i)" => '2003', "date(2i)" => "12", "date(3i)" => "25"})
    @session.selects_date "December 25, 2003"
    @session.click_button
  end

  it "should fail if the specified label is not found" do
    @session.response_body = <<-EOS
      <form method="post" action="/appointments">
        <select name="month"><option>January</option></select>
        <input type="submit" />
      </form>
    EOS
    
    lambda { @session.selects_date "December 25, 2003", :from => "date" }.should raise_error
  end

end
