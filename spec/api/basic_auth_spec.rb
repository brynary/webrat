require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Basic Auth HTTP headers" do
  before do
    @session = Webrat::TestSession.new
    @session.basic_auth('user', 'secret')
  end

  it "should be present in visits" do
    @session.should_receive(:get).with("/", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ=\n"})
    @session.visits("/")
  end
  
  it "should be present in form submits" do
    @session.response_body = <<-EOS
      <form method="post" action="/form1">
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/form1", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ=\n"})
    @session.clicks_button
  end
end
