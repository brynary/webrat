require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Webrat
  describe CheckboxField do
    it "should say it is checked if it is" do
      checkbox = CheckboxField.new(nil, (Webrat::XML.document("<input type='checkbox' checked='checked'>").search('input')).first)
      checkbox.should be_checked
    end

    it "should say it is not checked if it is not" do
      checkbox = CheckboxField.new(nil, (Webrat::XML.document("<input type='checkbox'>").search('input')).first)
      checkbox.should_not be_checked
    end
  end
  
  describe RadioField do
    it "should say it is checked if it is" do
      radio_button = RadioField.new(nil, (Webrat::XML.document("<input type='radio' checked='checked'>").search('input')).first)
      radio_button.should be_checked
    end

    it "should say it is not checked if it is not" do
      radio_button = RadioField.new(nil, (Webrat::XML.document("<input type='radio'>").search('input')).first)
      radio_button.should_not be_checked
    end
  end
end
