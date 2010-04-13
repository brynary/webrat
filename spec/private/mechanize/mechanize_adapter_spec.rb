require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Webrat::MechanizeAdapter do

  Mechanize = WWW::Mechanize if defined?(WWW::Mechanize)

  before :each do
    Webrat.configuration.mode = :mechanize
  end

  before(:each) do
    @mech = Webrat::MechanizeAdapter.new
  end

  describe "mechanize" do
    it "should disable the following of redirects on the mechanize instance" do
      mech = @mech.mechanize
      mech.redirect_ok.should be_false
    end
  end

  describe "post" do
    def url
      'http://test.host/users'
    end

    def data
      {:user => {:first_name => 'Nancy', :last_name => 'Callahan'}}
    end

    def flattened_data
      {'user[first_name]' => 'Nancy', 'user[last_name]' => 'Callahan'}
    end

    it "should flatten model post data" do
      mechanize = mock(:mechanize)
      mechanize.stub!(:redirect_ok=)
      Mechanize.stub!(:new => mechanize)
      mechanize.should_receive(:post).with(url, flattened_data)
      Webrat::MechanizeAdapter.new.post(url, data)
    end
  end

  describe "#absolute_url" do
    before(:each) do
      @session = Webrat::MechanizeAdapter.new
      @session.stub!(:current_url).and_return(absolute_url)
    end

    def absolute_url
      'http://test.host/users/fred/cabbages'
    end

    def rooted_url
      '/users/fred/cabbages'
    end

    def relative_url
      '../../wilma'
    end

    it "should return unmodified url if prefixed with scheme" do
      @session.absolute_url(absolute_url).should == absolute_url
    end

    it "should prefix scheme and hostname if url begins with /" do
      @session.absolute_url(rooted_url).should == absolute_url
    end

    it "should resolve sibling URLs relative to current path" do
      @session.absolute_url(relative_url).should == 'http://test.host/users/wilma'
    end

    it "should cope with sibling URLs from root of site" do
      @session.stub!(:current_url).and_return('http://test.host')
      @session.absolute_url(relative_url).should == 'http://test.host/wilma'
    end

    it "should cope with https" do
      @session.stub!(:current_url).and_return('https://test.host')
      @session.absolute_url(relative_url).should == 'https://test.host/wilma'
    end
  end

  describe "response_headers" do
    it "should return the Headers object from the response" do
      mech = @mech.mechanize
      resp = mock('Mechanize::File')
      hdr = Mechanize::Headers.new
      resp.should_receive(:header).and_return(hdr)
      mech.stub!(:get).and_return(resp)
      @mech.get('/', nil)
      @mech.response_headers.should == hdr
    end
  end
end
