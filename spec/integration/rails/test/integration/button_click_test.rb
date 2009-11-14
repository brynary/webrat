require 'test_helper'

class ButtonClickTest < ActionController::IntegrationTest
  # <button type="submit" ...>
  test "should click button with type submit by id" do
    visit buttons_path
    click_button "button_submit_id"
    assert_contain "success"
  end
  test "should click button with type submit by value" do
    visit buttons_path
    click_button "button_submit_value"
    assert_contain "success"
  end
  test "should click button with type submit by html" do
    visit buttons_path
    click_button "button_submit_text"
    assert_contain "success"
  end

  # <button type="image" ...>
  test "should click button with type image by id" do
    visit buttons_path
    click_button "button_image_id"
    assert_contain "success"
  end
  test "should click button with type image by value" do
    visit buttons_path
    click_button "button_image_value"
    assert_contain "success"
  end
  test "should click button with type image by html" do
    visit buttons_path
    click_button "button_image_text"
    assert_contain "success"
  end

  # <input type="submit" ...>
  test "should click input with type submit by id" do
    visit buttons_path
    click_button "input_submit_id"
    assert_contain "success"
  end
  test "should click input with type submit by value" do
    visit buttons_path
    click_button "input_submit_value"
    assert_contain "success"
  end

  # <input type="image" ...>
  test "should click input with type image by id" do
    visit buttons_path
    click_button "input_image_id"
    assert_contain "success"
  end
  test "should click input with type image by value" do
    visit buttons_path
    click_button "input_image_value"
    assert_contain "success"
  end
  test "should click input with type image by alt" do
    visit buttons_path
    click_button "input_image_alt"
    assert_contain "success"
  end
end
