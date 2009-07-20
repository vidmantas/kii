require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users(:admin)
  end
  
  test "visibility of profile text" do
    @user.update_attribute(:profile_text, "")
    get :show, :id => @user.to_param
    assert_select "body:not(#user_profile_text)"
    
    @user.update_attribute(:profile_text, "Something.")
    get :show, :id => @user.to_param
    assert_select "#user_profile_text"
  end
end
