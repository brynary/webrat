require File.expand_path(File.dirname(__FILE__) + "/../../../lib/webrat/mechanize")

describe Webrat::MechanizeSession do
  before(:each) do
    @mech = Webrat::MechanizeSession.new
  end
  
  describe "headers method" do
    it "should return empty headers for a newly initialized session" do
      @mech.headers.should == {}
    end
  end
end