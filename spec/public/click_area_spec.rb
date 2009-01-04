require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "click_area" do
  it "should use get by default" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_area "Berlin"
  end

  it "should assert valid response" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.response_code = 501
    lambda { click_area "Berlin" }.should raise_error(Webrat::PageLoadError)
  end

  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      with_html <<-HTML
        <html>
        <map name="map_de" id="map_de">
        <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
        </map>
        </html>
      HTML
      webrat_session.stub!(:redirect? => false)
      webrat_session.response_code = status
      lambda { click_area "Berlin" }.should_not raise_error
    end
  end

  it "should fail if the area doesn't exist" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML

    lambda {
      click_area "Missing area"
    }.should raise_error(Webrat::NotFoundError)
  end

  it "should not be case sensitive" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_area "berlin"
  end


  it "should follow relative links" do
    webrat_session.stub!(:current_url => "/page")
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="sub" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/page/sub", {})
    click_area "Berlin"
  end

  it "should follow fully qualified local links" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="http://www.example.com/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.should_receive(:get).with("http://www.example.com/page", {})
    click_area "Berlin"
  end

  it "should follow query parameters" do
    with_html <<-HTML
      <html>
      <map name="map_de" id="map_de">
      <area href="/page?foo=bar" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
      </html>
    HTML
    webrat_session.should_receive(:get).with("/page?foo=bar", {})
    click_area "Berlin"
  end
end
