require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Webrat
  describe Field do
    it "should have nice inspect output" do
      html = <<-HTML
        <html>
        <input type='checkbox' checked='checked' />
        </html>
      HTML

      element = Webrat::XML.document(html).css("input").first
      checkbox = CheckboxField.new(nil, element)
      checkbox.inspect.should =~ /^#<Webrat::CheckboxField @element=/
    end
  end

  describe CheckboxField do
    it "should say it is checked if it is" do
      html = <<-HTML
        <html>
        <input type='checkbox' checked='checked' />
        </html>
      HTML

      element = Webrat::XML.document(html).css("input").first
      checkbox = CheckboxField.new(nil, element)
      checkbox.should be_checked
    end

    it "should say it is not checked if it is not" do
      html = <<-HTML
        <html>
        <input type='checkbox' />
        </html>
      HTML

      element = Webrat::XML.document(html).css("input").first
      checkbox = CheckboxField.new(nil, element)
      checkbox.should_not be_checked
    end
  end

  describe RadioField do
    it "should say it is checked if it is" do
      html = <<-HTML
        <html>
        <input type='radio' checked='checked' />
        </html>
      HTML

      element = Webrat::XML.document(html).css("input").first
      radio_button = RadioField.new(nil, element)
      radio_button.should be_checked
    end

    it "should say it is not checked if it is not" do
      html = <<-HTML
        <html><input type='radio' /></html>
      HTML

      element = Webrat::XML.document(html).css("input").first
      radio_button = RadioField.new(nil, element)
      radio_button.should_not be_checked
    end
  end

  describe TextField do
    it 'should not escape values in mechanize mode' do
      Webrat.configuration.mode = :mechanize

      html = <<-HTML
        <html>
          <input type="text" name="email" value="user@example.com" />
        </html>
      HTML

      element    = Webrat::XML.document(html).css('input').first
      text_field = TextField.new(nil, element)
      text_field.to_param.should == { 'email' => 'user@example.com' }
    end
  end
end
