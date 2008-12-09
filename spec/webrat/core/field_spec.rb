require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Webrat
  describe CheckboxField do
    it "should say it is checked if it is" do
      html = <<-HTML
        <html>
        <input type='checkbox' checked='checked' />
        </html>
      HTML
      
      element = Webrat::XML.css_search(Webrat::XML.document(html), "input").first
      checkbox = CheckboxField.new(nil, element)
      checkbox.should be_checked
    end

    it "should say it is not checked if it is not" do
      html = <<-HTML
        <html>
        <input type='checkbox' />
        </html>
      HTML
      
      element = Webrat::XML.css_search(Webrat::XML.document(html), "input").first
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
      
      element = Webrat::XML.css_search(Webrat::XML.document(html), "input").first
      radio_button = RadioField.new(nil, element)
      radio_button.should be_checked
    end

    it "should say it is not checked if it is not" do
      html = <<-HTML
        <html><input type='radio' /></html>
      HTML
      
      element = Webrat::XML.css_search(Webrat::XML.document(html), "input").first 
      radio_button = RadioField.new(nil, element)
      radio_button.should_not be_checked
    end
  end
end
