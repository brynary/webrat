require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Link do
#  include Webrat::Link

  before do
    @session = mock(Webrat::TestSession)
    @link_text_with_nbsp = 'Link' + [0xA0].pack("U") + 'Text'
  end
  
  it "should pass through relative urls" do
    link = Webrat::Link.new(@session, {"href" => "/path"})
    @session.should_receive(:request_page).with("/path", :get, {})
    link.click
  end
  
  it "shouldnt put base url onto " do
    url = "https://www.example.com/path"
    @session.should_receive(:request_page).with(url, :get, {})
    link = Webrat::Link.new(@session, {"href" => url})
    link.click
  end
  
  it "should matches_text? on regexp" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return(@link_text_with_nbsp)
    link.matches_text?(/link/i).should == 0
  end
  
  it "should matches_text? on link_text" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return(@link_text_with_nbsp)
    link.matches_text?("Link Text").should == 0
  end
  
  it "should matches_text? on substring" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return(@link_text_with_nbsp)
    link.matches_text?("nk Te").should_not be_nil
  end
  
  it "should not matches_text? on link_text case insensitive" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return(@link_text_with_nbsp)
    link.should_receive(:inner_html).and_return('Link&nbsp;Text')
    link.should_receive(:title).and_return(nil)
    link.matches_text?("link_text").should == false
  end
  
  it "should match text not include &nbsp;" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return('LinkText')
    link.matches_text?("LinkText").should == 0
  end
  
  it "should not matches_text? on wrong text" do 
    link = Webrat::Link.new(@session, nil)
    nbsp = [0xA0].pack("U")
    link.should_receive(:text).and_return("Some"+nbsp+"Other"+nbsp+"Link")
    link.should_receive(:inner_html).and_return("Some&nbsp;Other&nbsp;Link")
    link.should_receive(:title).and_return(nil)
    link.matches_text?("Link Text").should == false
  end

  it "should match text including character reference" do
    no_ko_gi_ri = [0x30CE,0x30B3,0x30AE,0x30EA]
    nokogiri_ja_kana = no_ko_gi_ri.pack("U*")
    nokogiri_char_ref = no_ko_gi_ri.map{|c| "&#x%X;" % c }.join("")

    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return(nokogiri_ja_kana)
    link.matches_text?(nokogiri_ja_kana).should == 0
  end

  it "should match img link" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:text).and_return('')
    link.should_receive(:inner_html).and_return('<img src="logo.png" />')
    link.matches_text?('logo.png').should == 10
  end

  it "should matches_id? on exact matching id" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("some_id")
    link.matches_id?("some_id").should == true
  end
  
  it "should not matches_id? on incorrect id" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("other_id")
    link.matches_id?("some_id").should == false
  end
  
  it "should matches_id? on matching id by regexp" do
    link = Webrat::Link.new(@session, nil)
    link.should_receive(:id).and_return("some_id")
    link.matches_id?(/some/).should == true
  end
  
end
