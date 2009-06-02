require 'test_helper'

class FillInTest < ActionController::IntegrationTest
  test "should fill in text field by name" do
    visit fields_path
    fill_in "field_by_name", :with => "value"
  end
  test "should fill in text field by name, rails naming lh257" do
    visit fields_path
    fill_in "rails[naming]", :with => "value"
  end
  test "should fill in text field by id" do
    visit fields_path
    fill_in "field_by_id", :with => "value"
  end
  test "should fill in text field by label via id" do
    visit fields_path
    fill_in "FieldByLabelId", :with => "value"
  end
  test "should fill in text field by label with special characters" do
    visit fields_path
    fill_in "[Field]:", :with => "value"
  end
end