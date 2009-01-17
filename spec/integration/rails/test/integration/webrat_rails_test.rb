require 'test_helper'

class WebratTest < ActionController::IntegrationTest
  
  test "should scope within an object" do
    visit root_path
    
    within FakeModel.new do
      fill_in "Object field", :with => "Test"
      
      assert_raise Webrat::NotFoundError do
        check "TOS"
      end
    end
  end
  
end
