require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "save_and_open_page" do
  before do
    @session = Webrat::TestSession.new

    @session.response_body = <<-HTML
      <html>
        <head>
          <link href="/stylesheets/foo.css" media="screen" rel="stylesheet" type="text/css" />
        </head>
        <body>
          <h1>Hello world</h1>
          <img src="/images/bar.png" />
        </body>
      </html>
    HTML

    File.stub!(:exist?).and_return(true)
    Time.stub!(:now).and_return(1234)
    @session.stub!(:open_in_browser)
    
    @file_handle = mock("file handle")
    File.stub!(:open).with(filename, 'w').and_yield(@file_handle)
    @file_handle.stub!(:write)
  end

  it "should rewrite css rules" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|#{@session.doc_root}/stylesheets/foo.css|s
    end
    
    @session.save_and_open_page
  end
  
  it "should rewrite image paths" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|#{@session.doc_root}/images/bar.png|s
    end
    
    @session.save_and_open_page
  end
  
  it "should open the temp file in a browser" do
    @session.should_receive(:open_in_browser).with(filename)
    @session.save_and_open_page
  end
  
  def filename
    File.expand_path("./webrat-#{Time.now}.html")
  end

end
