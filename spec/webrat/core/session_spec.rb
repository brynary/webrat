require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Session do
  
  it "should not have a doc_root" do
    session = Webrat::Session.new
    session.doc_root.should be_nil
  end
  
  it "should expose the current_dom" do
    session = Webrat::Session.new
    
    def session.response
      Object.new
    end
    
    def session.response_body
      "<html></html>"
    end
    
    session.current_dom.should be_an_instance_of(Nokogiri::HTML::Document)
  end
  
  it "should open the page in the browser" do
    session = Webrat::Session.new
    session.should_receive(:`).with("open path")
    session.open_in_browser("path")
  end
  
  it "should provide a current_page for backwards compatibility" do
    session = Webrat::Session.new
    current_page = session.current_page
    current_page.should_not be_nil
    current_page.should respond_to(:url)
  end

  it "should allow custom headers to be set" do
    session = Webrat::Session.new
    session.header('Accept', 'application/xml')

    session.instance_variable_get(:@custom_headers)['Accept'].should == 'application/xml'
  end

  it "should return a copy of the headers to be sent" do
    session = Webrat::Session.new
    session.instance_eval { 
      @default_headers = {'HTTP_X_FORWARDED_FOR' => '192.168.1.1'}
      @custom_headers = {'Accept' => 'application/xml'}
    }
    session.headers.should == {'HTTP_X_FORWARDED_FOR' => '192.168.1.1', 'Accept' => 'application/xml'}
  end

  describe "#http_accept" do
    before(:each) do
      @session = Webrat::Session.new
    end

    it "should set the Accept header with the string Mime type" do
      @session.http_accept('application/xml')
      @session.headers['Accept'].should == 'application/xml'
    end

    it "should set the Accept head with the string value of the symbol Mime type" do
      @session.http_accept(:xml)
      @session.headers['Accept'].should == 'application/xml'
    end

    it "should raise an error if a symbol Mime type is passed that does not exist" do
      lambda { @session.http_accept(:oogabooga) }.should raise_error(ArgumentError)
    end
  end

  describe "#request_page" do
    before(:each) do
      @session = Webrat::Session.new
    end
  
    it "should raise an error if the request is not a success" do
      @session.stub!(:get)
      @session.stub!(:response_body).and_return("Exception caught")
      @session.stub!(:response_code).and_return(500)
      @session.stub!(:formatted_error).and_return("application error")
      @session.stub!(:save_and_open_page)
  
      lambda { @session.request_page('some url', :get, {}) }.should raise_error(Webrat::PageLoadError)
    end
  end
end
