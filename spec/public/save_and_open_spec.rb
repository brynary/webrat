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
    Launchy.stub!(:open)

    @file_handle = mock("file handle")
    File.stub!(:open).and_yield(@file_handle)
    @file_handle.stub!(:write)
  end

  it "should save pages to the directory configured" do
    Webrat.configuration.stub!(:saved_pages_dir => "path/to/dir")
    File.should_receive(:open).with("path/to/dir/webrat-1234.html", "w").and_yield(@file_handle)

    save_and_open_page
  end

  it "should open the temp file in a browser with Launchy" do
    Launchy.should_receive(:open)
    save_and_open_page
  end

  it "should fail gracefully if Launchy is not available" do
    Launchy.should_receive(:open).and_raise(LoadError)

    lambda do
      save_and_open_page
    end.should_not raise_error
  end

end
