require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "click_area" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should use get by default" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_area "Berlin"
  end

  it "should assert valid response" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.response_code = 501
    lambda { @session.click_area "Berlin" }.should raise_error
  end
  
  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      @session.response_body = <<-EOS
        <map name="map_de" id="map_de">
        <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
        </map>
      EOS
      @session.response_code = status
      lambda { @session.click_area "Berlin" }.should_not raise_error
    end
  end
  
  it "should fail if the area doesn't exist" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    
    lambda {
      @session.click_area "Missing area"
    }.should raise_error
  end
  
  it "should not be case sensitive" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.should_receive(:get).with("/page", {})
    @session.click_area "berlin"
  end
  

  it "should follow relative links" do
    @session.stub!(:current_url).and_return("/page")
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="sub" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.should_receive(:get).with("/page/sub", {})
    @session.click_area "Berlin"
  end
  
  it "should follow fully qualified local links" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="http://www.example.com/page" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.should_receive(:get).with("http://www.example.com/page", {})
    @session.click_area "Berlin"
  end

  it "should follow query parameters" do
    @session.response_body = <<-EOS
      <map name="map_de" id="map_de">
      <area href="/page?foo=bar" title="Berlin" id="berlin" shape="poly" alt="Berlin" coords="180,89,180" />
      </map>
    EOS
    @session.should_receive(:get).with("/page?foo=bar", {})
    @session.click_area "Berlin"
  end
end
