require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "attach_file" do
  before do
    Webrat.configuration.mode = :rails
    @filename = __FILE__
    @uploaded_file = mock("uploaded file")
    ActionController::TestUploadedFile.stub!(:new => @uploaded_file)
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
    webrat_session.should_receive(:post).with("/widgets", { "widget" => { "file" => @uploaded_file } })
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
    webrat_session.should_receive(:post).with("/widgets", { "widget" => { "files" => [@uploaded_file, @uploaded_file] } })
    attach_file "Document", @filename
    attach_file "Spreadsheet", @filename
    click_button
  end

  it "should allow the content type to be specified" do
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

  it "should support nested attributes" do
    with_html <<-HTML
      <html>
      <form method="post" action="/albums">
        <label for="photo_file1">Photo</label>
        <input type="file" id="photo_file1" name="album[photos_attributes][][image]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/albums", { "album" => { "photos_attributes" => [{"image" => @uploaded_file}] } })
    attach_file "Photo", @filename
    click_button
  end

  it "should support nested attributes with multiple files" do
    with_html <<-HTML
      <html>
      <form method="post" action="/albums">
        <label for="photo_file1">Photo 1</label>
        <input type="file" id="photo_file1" name="album[photos_attributes][][image]" />
        <label for="photo_file2">Photo 2</label>
        <input type="file" id="photo_file2" name="album[photos_attributes][][image]" />
        <input type="submit" />
      </form>
      </html>
    HTML
    webrat_session.should_receive(:post).with("/albums", { "album" => { "photos_attributes" => [{"image" => @uploaded_file}, {"image" => @uploaded_file}] } })
    attach_file "Photo 1", @filename
    attach_file "Photo 2", @filename
    click_button
  end
end
