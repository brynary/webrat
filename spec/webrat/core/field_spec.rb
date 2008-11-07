require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

module Webrat
  describe CheckboxField do
    it "should say it is checked if it is" do
      checkbox = CheckboxField.new(nil, (Webrat.nokogiri_document("<input type='checkbox' checked='checked'>")/'input').first)
      checkbox.should be_checked
    end

    it "should say it is not checked if it is not" do
      checkbox = CheckboxField.new(nil, (Webrat.nokogiri_document("<input type='checkbox'>")/'input').first)
      checkbox.should_not be_checked
    end
  end
end
