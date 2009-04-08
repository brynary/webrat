require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "reloads" do
  it "should reload the page with http referer" do
    webrat_session.should_receive(:get).with("http://www.example.com/", {})
    visit("/")
    webrat_session.should_receive(:get).with("http://www.example.com/", {}, {"HTTP_REFERER"=>"http://www.example.com/"})
    reload
  end
end
