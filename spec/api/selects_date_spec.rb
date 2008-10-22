require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "date_selects" do
  before do
    @session = Webrat::TestSession.new
    @example_date_select = <<-EOS
      <form method="post" action="/login">
        <label for="created_at">Created at</label><br />
        <select id="created_at_1i" name="created_at(1i)">
          <option value="2002">2002</option>
          <option value="2003">2003</option>
        </select>
        <select id="created_at_2i" name="created_at(2i)">
          <option value="11">November</option>
          <option value="12">December</option>
        </select>
        <select id="created_at_3i" name="created_at(3i)">
          <option value="1">1</option>
          <option value="2">2</option>
        </select>
        <input type="button" value="submit"/>
      </form>
    EOS
  end
  
  
  it "should fail if option not found" do
    @session.response_body = @example_date_select
    lambda { @session.selects_date "2008-07-13"}.should raise_error
  end
  
  it "should fail if option not found in list specified by element name" do
    @session.response_body = @example_date_select
    lambda { @session.selects_date "2008-07-13", :from => "created_at" }.should raise_error
  end
  
  it "should fail if specified list not found" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
        <select name="month"><option value="1">January</option></select>
      </form>
    EOS

    lambda { @session.selects_date "2003-12-01", :from => "created_at" }.should raise_error
  end
  
  it "should send value from option" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="updated_at">Created at</label><br />
        <select id="updated_at_1i" name="updated_at(1i)">
          <option value=""></option>
          <option value="2003">2003</option>
        </select>
        <select id="updated_at_2i" name="updated_at(2i)">
          <option value=""></option>
          <option value="12">December</option>
        </select>
        <select id="updated_at_3i" name="updated_at(3i)">
          <option value=""></option>
          <option value="1">1</option>
        </select>
        <label for="created_at">Created at</label><br />
        <select id="created_at_1i" name="created_at(1i)">
          <option value="2003">2003</option>
        </select>
        <select id="created_at_2i" name="created_at(2i)">
          <option value="12">December</option>
        </select>
        <select id="created_at_3i" name="created_at(3i)">
          <option value="1">1</option>
        </select>
        <input type="button" value="submit"/>
      </form>
    EOS
    @session.should_receive(:post).with("/login", "created_at(1i)" => "2003", 'created_at(2i)' => '12', 'created_at(3i)' => '1', "updated_at(1i)" => "", 'updated_at(2i)' => '', 'updated_at(3i)' => '')
    @session.selects_date '2003-12-01', :from => "created_at"
    @session.clicks_button
  end
  
  it "should work without specifying the field name or label" do
    @session.response_body = @example_date_select
    @session.should_receive(:post).with("/login", "created_at(1i)" => "2003", 'created_at(2i)' => '12', 'created_at(3i)' => '1')
    @session.selects_date '2003-12-01'
    @session.clicks_button
  end
  
  it "should correctly set day and month when there are the same options available" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="created_at">Created at</label><br />
        <select id="created_at_1i" name="created_at(1i)">
          <option value="2003">2003</option>
        </select>
        <select id="created_at_2i" name="created_at(2i)">
          <option value="1">January</option>
          <option value="12">December</option>
        </select>
        <select id="created_at_3i" name="created_at(3i)">
          <option value="1">1</option>
          <option value="12">12</option>
        </select>
        <input type="button" value="submit"/>
      </form>
    EOS
    @session.should_receive(:post).with("/login", "created_at(1i)" => "2003", 'created_at(2i)' => '12', 'created_at(3i)' => '1')
    @session.selects_date '2003-12-01'
    @session.clicks_button
  end
  
end
