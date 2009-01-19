require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "reloads" do
  it "should reload the page with http referer" do
    webrat_session.should_receive(:get).with("/", {})
    webrat_session.should_receive(:get).with("/", {}, {"HTTP_REFERER"=>"/"})
    visit("/")
    reload
  end
end
