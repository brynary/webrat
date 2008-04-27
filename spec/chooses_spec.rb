require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "chooses" do
  before do
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end
  
  it "should fail if no radio buttons found" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
      </form>
    EOS
    
    lambda { @session.chooses "first option" }.should raise_error
  end
  
  it "should fail if input is not a radio button" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="text" name="first_option" />
      </form>
    EOS
    
    lambda { @session.chooses "first_option" }.should raise_error
  end
  
  it "should check rails style radio buttons" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"gender" => "M"})
    @session.chooses "Male"
    @session.clicks_button
  end
  
  it "should only submit last chosen value" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="get" action="/login">
        <input id="user_gender_male" name="user[gender]" type="radio" value="M" />
        <label for="user_gender_male">Male</label>
        <input id="user_gender_female" name="user[gender]" type="radio" value="F" />
        <label for="user_gender_female">Female</label>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:get_via_redirect).with("/login", "user" => {"gender" => "M"})
    @session.chooses "Female"
    @session.chooses "Male"
    @session.clicks_button
  end  
  
  it "should result in the value on being posted if not specified" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="radio" name="first_option" />
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "first_option" => "on")
    @session.chooses "first_option"
    @session.clicks_button
  end
  
  it "should result in the value on being posted if not specified and checked by default" do
    @response.stubs(:body).returns(<<-EOS)
      <form method="post" action="/login">
        <input type="radio" name="first_option" checked="checked"/>
        <input type="submit" />
      </form>
    EOS
    @session.expects(:post_via_redirect).with("/login", "first_option" => "on")
    @session.clicks_button
  end
end
