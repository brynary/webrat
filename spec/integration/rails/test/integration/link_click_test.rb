require 'test_helper'

class LinkClickTest < ActionController::IntegrationTest
  test "should click link by text" do
    visit links_path
    click_link "LinkByText"
    assert_contain("Link:LinkByText")
  end

  test "should click link by id" do
    visit links_path
    click_link "link_by_id"
    assert_contain("Link:link_by_id")
  end

  test "should click link by title" do
    visit links_path
    click_link "LinkByTitle"
    assert_contain("Link:LinkByTitle")
  end

  test "should be able to click links with non letter characters" do
    visit links_path
    click_link "Link With (parens)"
    assert_contain("Link:link_with_parens")
  end
end