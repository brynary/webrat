require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "mechanize"
require "webrat/mechanize"

describe Webrat::MechanizeSession do
  before(:each) do
    @mech = Webrat::MechanizeSession.new
  end
  
  describe "headers method" do
    it "should return empty headers for a newly initialized session" do
      @mech.headers.should == {}
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
      WWW::Mechanize.stub!(:new => mechanize)
      mechanize.should_receive(:post).with(url, flattened_data)
      Webrat::MechanizeSession.new.post(url, data)
    end
  end
end