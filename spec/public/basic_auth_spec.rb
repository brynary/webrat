require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Basic Auth HTTP headers" do
  before do
    basic_auth('user', 'secret')
  end

  it "should be present in visit" do
    webrat_session.should_receive(:get).with("/", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ="})
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
    webrat_session.should_receive(:post).with("/form1", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQ="})
    click_button
  end

  context "with long username and password combination" do
    before do
      basic_auth('user', 'secret1234567890123456789012345678901234567890123456789012345678901234567890')
    end

    it "should be present, without new lines, in visit" do
      webrat_session.should_receive(:get).with("/", {}, {'HTTP_AUTHORIZATION' => "Basic dXNlcjpzZWNyZXQxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkw"})
      visit("/")
    end
  end
end
