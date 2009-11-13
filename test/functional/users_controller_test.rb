require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = Factory(:user)
  end
  
  test "visibility of profile text" do
    @user.update_attribute(:profile_text, "")
    get :show, :id => @user.to_param
    assert_select "body:not(.box_thingie)"
    
    @user.update_attribute(:profile_text, "Something.")
    get :show, :id => @user.to_param
    assert_select ".box_thingie"
  end
  
  test "revisions" do
    get :revisions, :id => @user.to_param
    assert_response :success
  end
  
  test "discussions" do
    get :discussions, :id => @user.to_param
    assert_response :success
  end
end
