require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/helper")

describe HashWithIndifferentAccess do
  it "should not update constructor when not a hash" do
    HashWithIndifferentAccess.should_receive(:update).never
    HashWithIndifferentAccess.new('test')
  end
  
  it "should get the default for key" do
    h = HashWithIndifferentAccess.new(:test => 'me')
    h.should_receive(:super).never
    
    h.default(:test).should == 'me'
  end
  
  context "a hash with a test value applied" do
    
    setup do
      @h = HashWithIndifferentAccess.new
      @h[:test] = 'me'
    end
    
    it "should assign a new value" do
      @h[:test].should == 'me'
    end
    
    it "should return true if asked for existing key" do
      @h.key?(:test).should be_true
    end
  
    it "should return array of values for keys" do
      @h.values_at(:test).should == ['me']
    end
    
    it "should merge with another hash" do
      another = HashWithIndifferentAccess.new(:value => 'test')
      @h.merge(another).values_at(:test, :value).should == ['me','test']
    end
  
    it "should delete the key" do
      @h.delete(:test)
      @h.any?.should be_false
      @h[:test].should be_nil
    end
    
  end
end