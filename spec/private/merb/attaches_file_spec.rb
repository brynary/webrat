require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "attach_file with merb" do
  before do
    Webrat.configuration.mode = :merb
    @filename = __FILE__
  end

  it "should fail if no file field found" do
    with_html <<-HTML
      <html>
      <form method="post" action="/widgets">
      </form>
      </html>
    HTML
    lambda { attach_file("Doc", "/some/path") }.should raise_error(Webrat::NotFoundError)
  end

  it "should submit empty strings for blank file fields" do
    with_html <<-HTML
      <html>
      <form method="post" action="/widgets">
        <input type="file" id="widget_file" name="widget[file]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/widgets", { "widget" => { "file" => "" } })
    click_button
  end

  it "should submit the attached file" do
    with_html <<-HTML
      <html>
      <form method="post" action="/widgets">
        <label for="widget_file">Document</label>
        <input type="file" id="widget_file" name="widget[file]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with { |path, params|
      path.should == "/widgets"
      params.should have_key("widget")
      params["widget"].should have_key("file")
      params["widget"]["file"].should be_an_instance_of(File)
      params["widget"]["file"].path.should == @filename
    }
    attach_file "Document", @filename
    click_button
  end

  it "should support collections" do
    with_html <<-HTML
      <html>
      <form method="post" action="/widgets">
        <label for="widget_file1">Document</label>
        <input type="file" id="widget_file1" name="widget[files][]" />
        <label for="widget_file2">Spreadsheet</label>
        <input type="file" id="widget_file2" name="widget[files][]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with { |path, params|
      path.should == "/widgets"
      params.should have_key("widget")
      params["widget"].should have_key("files")
      params["widget"]["files"][0].should be_an_instance_of(File)
      params["widget"]["files"][0].path.should == @filename
      params["widget"]["files"][1].should be_an_instance_of(File)
      params["widget"]["files"][1].path.should == @filename
    }
    attach_file "Document", @filename
    attach_file "Spreadsheet", @filename
    click_button
  end

  xit "should allow the content type to be specified" do
    with_html <<-HTML
      <html>
      <form method="post" action="/widgets">
        <label for="person_picture">Picture</label>
        <input type="file" id="person_picture" name="person[picture]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    ActionController::TestUploadedFile.should_receive(:new).with(@filename, "image/png").any_number_of_times
    attach_file "Picture", @filename, "image/png"
    click_button
  end
end
