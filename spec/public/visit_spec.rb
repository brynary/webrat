require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "visit" do
  before do
    with_html <<-HTML
      <html>
      Hello world
      </html>
    HTML
  end

  it "should use get" do
    webrat_session.should_receive(:get).with("/", {})
    visit("/")
  end

  it "should assert valid response" do
    webrat_session.response_code = 501
    lambda { visit("/") }.should raise_error(Webrat::PageLoadError)
  end

  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      webrat_session.stub!(:redirect? => false)
      webrat_session.response_code = status
      lambda { visit("/") }.should_not raise_error
    end
  end

  it "should require a visit before manipulating page" do
    lambda { fill_in "foo", :with => "blah" }.should raise_error(Webrat::WebratError)
  end

  it "should not follow external redirects" do
    webrat_session.should_receive(:internal_redirect?).and_return(false)

    visit("/oldurl")

    current_url.should == "/oldurl"
  end
end

describe "visit with referer" do
  before do
    webrat_session.instance_variable_set(:@current_url, "/old_url")
    with_html <<-HTML
      <html>
      Hello world
      </html>
    HTML
  end

  it "should use get with referer header" do
    webrat_session.should_receive(:get).with("/", {}, {"HTTP_REFERER" => "/old_url"})
    visit("/")
  end

end
