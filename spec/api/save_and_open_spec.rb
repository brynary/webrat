require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

describe "save_and_open_page" do
  before do
    @session = Webrat::TestSession.new

    @session.response_body = <<-HTML
    <html><head>
      <link href="/stylesheets/foo.css" media="screen" rel="stylesheet" type="text/css" />
    </head><body>
      <h1>Hello world</h1>
      <img src="/images/bar.png" />
    </body></html>
    HTML

    File.stubs(:exist?).returns(true)
    Time.stubs(:now).returns(1234)
  end

  it "should rewrite css rules" do
    file_handle = mock()
    File.expects(:open).with(filename, 'w').yields(file_handle)
    file_handle.expects(:write).with{|html| html =~ %r|#{RAILS_ROOT}/public/stylesheets/foo.css|s }
    Webrat::Page.any_instance.stubs(:open_in_browser)
    @session.save_and_open_page
  end
  
  it "should rewrite image paths" do
    file_handle = mock()
    File.expects(:open).with(filename, 'w').yields(file_handle)
    file_handle.expects(:write).with{|html| html =~ %r|#{RAILS_ROOT}/public/images/bar.png|s }
    Webrat::Page.any_instance.stubs(:open_in_browser)
    @session.save_and_open_page
  end
  
  it "should open the temp file in a browser" do
    File.stubs(:open)
    Webrat::Page.any_instance.expects(:open_in_browser).with(filename)
    @session.save_and_open_page
  end
  
  def filename
    File.expand_path("./webrat-1234.html")
  end

end
