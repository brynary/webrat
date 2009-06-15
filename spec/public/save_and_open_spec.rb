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
          <img src='/images/foo.png' />
        </body>
      </html>
    HTML

    File.stub!(:exist? => true)
    Time.stub!(:now => 1234)

    require "launchy"
    Launchy::Browser.stub!(:run)

    @file_handle = mock("file handle")
    File.stub!(:open).with(filename, 'w').and_yield(@file_handle)
    @file_handle.stub!(:write)
  end

  it "should rewrite css rules" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|"#{webrat_session.doc_root}/stylesheets/foo.css"|s
    end

    save_and_open_page
  end

  it "should rewrite image paths with double quotes" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|"#{webrat_session.doc_root}/images/bar.png"|s
    end

    save_and_open_page
  end

  it "should rewrite image paths with single quotes" do
    @file_handle.should_receive(:write) do |html|
      html.should =~ %r|'#{webrat_session.doc_root}/images/foo.png'|s
    end

    save_and_open_page
  end

  it "should open the temp file in a browser with Launchy" do
    Launchy::Browser.should_receive(:run)
    save_and_open_page
  end

  it "should fail gracefully if Launchy is not available" do
    Launchy::Browser.should_receive(:run).and_raise(LoadError)

    lambda do
      save_and_open_page
    end.should_not raise_error
  end

  def filename
    File.expand_path("./webrat-#{Time.now}.html")
  end

end
