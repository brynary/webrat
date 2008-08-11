require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Webrat::Session do
  
  it "should not have a doc_root" do
    session = Webrat::Session.new
    session.doc_root.should be_nil
  end
  
  it "should expose the current_dom" do
    session = Webrat::Session.new
    
    def session.response_body
      "<html></html>"
    end
    
    session.current_dom.should be_an_instance_of(Hpricot::Doc)
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
  
end