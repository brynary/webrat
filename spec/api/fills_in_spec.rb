require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "fills_in" do
  before do
    @session = Webrat::TestSession.new
  end
  
  it "should work with textareas" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_text">User Text</label>
        <textarea id="user_text" name="user[text]"></textarea>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"text" => "filling text area"})
    @session.fills_in "User Text", :with => "filling text area"
    @session.clicks_button
  end
  
  it "should work with password fields" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <input id="user_text" name="user[text]" type="password" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"text" => "pass"})
    @session.fills_in "user_text", :with => "pass"
    @session.clicks_button
  end

  it "should fail if input not found" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
      </form>
    EOS
    
    lambda { @session.fills_in "Email", :with => "foo@example.com" }.should raise_error
  end
  
  it "should fail if input is disabled" do
    @session.response_body = <<-EOS
      <form method="get" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" type="text" disabled="disabled" />
        <input type="submit" />
      </form>
    EOS
    
    lambda { @session.fills_in "Email", :with => "foo@example.com" }.should raise_error
  end
  
  it "should allow overriding default form values" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "user[email]", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should choose the shortest label match" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_mail1">Some other mail</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
    EOS
    
    @session.should_receive(:post).with("/login", "user" => {"mail1" => "", "mail2" => "value"})
    @session.fills_in "Some", :with => "value"
    @session.clicks_button
  end
  
  it "should choose the first label match if closest is a tie" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_mail1">Some mail one</label>
        <input id="user_mail1" name="user[mail1]" type="text" />
        <label for="user_mail2">Some mail two</label>
        <input id="user_mail2" name="user[mail2]" type="text" />
        <input type="submit" />
      </form>
    EOS
    
    @session.should_receive(:post).with("/login", "user" => {"mail1" => "value", "mail2" => ""})
    @session.fills_in "Some mail", :with => "value"
    @session.clicks_button
  end
  
  it "should anchor label matches to start of label" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_email">Some mail</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    lambda { @session.fills_in "mail", :with => "value" }.should raise_error
  end
  
  it "should anchor label matches to word boundaries" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_email">Emailtastic</label>
        <input id="user_email" name="user[email]" value="test@example.com" type="text" />
      </form>
    EOS
    
    lambda { @session.fills_in "Email", :with => "value" }.should raise_error
  end
  
  it "should work with inputs nested in labels" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label>
          Email
          <input id="user_email" name="user[email]" value="test@example.com" type="text" />
        </label>
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "Email", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should work with full input names" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in "user[email]", :with => "foo@example.com"
    @session.clicks_button
  end
  
  it "should work with symbols" do
    @session.response_body = <<-EOS
      <form method="post" action="/login">
        <label for="user_email">Email</label>
        <input id="user_email" name="user[email]" type="text" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/login", "user" => {"email" => "foo@example.com"})
    @session.fills_in :email, :with => "foo@example.com"
    @session.clicks_button
  end
end
