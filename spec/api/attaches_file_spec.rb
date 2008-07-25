require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "attaches_file" do
  before do
    @session = Webrat::TestSession.new

    @filename = __FILE__
    @uploaded_file = mock("uploaded file")
    ActionController::TestUploadedFile.stub!(:new).and_return(@uploaded_file)
  end

  it "should fail if no file field found" do
    @session.response_body = <<-EOS
      <form method="post" action="/widgets">
      </form>
    EOS
    lambda { @session.attaches_file("Doc", "/some/path") }.should raise_error
  end

  it "should submit empty strings for blank file fields" do
    @session.response_body = <<-EOS
      <form method="post" action="/widgets">
        <input type="file" id="widget_file" name="widget[file]" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/widgets", { "widget" => { "file" => "" } })
    @session.clicks_button
  end

  it "should submit the attached file" do
    @session.response_body = <<-EOS
      <form method="post" action="/widgets">
        <label for="widget_file">Document</label>
        <input type="file" id="widget_file" name="widget[file]" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/widgets", { "widget" => { "file" => @uploaded_file } })
    @session.attaches_file "Document", @filename
    @session.clicks_button
  end

  it "should support collections" do
    @session.response_body = <<-EOS
      <form method="post" action="/widgets">
        <label for="widget_file1">Document</label>
        <input type="file" id="widget_file1" name="widget[files][]" />
        <label for="widget_file2">Spreadsheet</label>
        <input type="file" id="widget_file2" name="widget[files][]" />
        <input type="submit" />
      </form>
    EOS
    @session.should_receive(:post).with("/widgets", { "widget" => { "files" => [@uploaded_file, @uploaded_file] } })
    @session.attaches_file "Document", @filename
    @session.attaches_file "Spreadsheet", @filename
    @session.clicks_button
  end

  it "should allow the content type to be specified" do
    @session.response_body = <<-EOS
      <form method="post" action="/widgets">
        <label for="person_picture">Picture</label>
        <input type="file" id="person_picture" name="person[picture]" />
        <input type="submit" />
      </form>
    EOS
    ActionController::TestUploadedFile.should_receive(:new).with(@filename, "image/png").any_number_of_times
    @session.attaches_file "Picture", @filename, "image/png"
    @session.clicks_button
  end
end
