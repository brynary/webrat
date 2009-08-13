require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Link do
#  include Webrat::Link

  before do
    webrat_session = mock(Webrat::TestAdapter)
    @link_text_with_nbsp = 'Link' + [0xA0].pack("U") + 'Text'
  end

  it "should pass through relative urls" do
    link = Webrat::Link.new(webrat_session, {"href" => "/path"})
    webrat_session.should_receive(:request_page).with("/path", :get, {})
    link.click
  end

  it "shouldnt put base url onto " do
    url = "https://www.example.com/path"
    webrat_session.should_receive(:request_page).with(url, :get, {})
    link = Webrat::Link.new(webrat_session, {"href" => url})
    link.click
  end

end
