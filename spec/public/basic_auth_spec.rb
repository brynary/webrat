require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Basic Auth HTTP headers" do
  before do
    basic_auth('user', 'secret')
  end

  it "should be present in visit" do
    webrat_session.should_receive(:get).with("/", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ=\n"})
    visit("/")
  end

  it "should be present in form submits" do
    with_html <<-HTML
      <html>
      <form method="post" action="/form1">
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/form1", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ=\n"})
    click_button
  end
end
