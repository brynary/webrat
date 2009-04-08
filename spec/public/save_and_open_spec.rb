require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "save_and_open_page" do
  before do
    with_html <<-HTML
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

    File.stub!(:exist? => true)
    Time.stub!(:now => 1234)
    webrat_session.stub!(:open_in_browser)

    @file_handle = mock("file handle")
    File.stub!(:open).with(filename, 'w').and_yield(@file_handle)
    @file_handle.stub!(:write)
  end

  it "should rewrite css rules" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|#{webrat_session.doc_root}/stylesheets/foo.css|s
    end

    save_and_open_page
  end

  it "should rewrite image paths" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|#{webrat_session.doc_root}/images/bar.png|s
    end

    save_and_open_page
  end

  it "should open the temp file in a browser" do
    webrat_session.should_receive(:open_in_browser).with(filename)
    save_and_open_page
  end

  def filename
    File.expand_path("./webrat-#{Time.now}.html")
  end

end
