require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  def setup
    # We want to make sure a page is being listed
    Factory(:page, :title => "A generic page.")
  end
  
  test "index" do
    get :index
    assert_redirected_to revisions_activities_path
  end
  
  test "revisions" do
    get :revisions
    assert_response :success
    assert_template "activities/revisions"
  end
  
  test "revisions rss" do
    get :revisions, :format => "rss"
    assert_response :success
    assert_template "activities/revisions.rss.erb"
  end
  
  test "others revisions" do
    @user = Factory(:user)
    Factory(:page, :revision_attributes => {:user_id => @user.id})
    
    get :others_revisions, :id => @user.id
    assert_response :success
    assert_template "activities/others_revisions"
  end
  
  test "others revision rss" do
    @user = Factory(:user)
    Factory(:page, :revision_attributes => {:user_id => @user.id})
    
    get :others_revisions, :id => @user.id, :format => "rss"
    assert_response :success
    assert_template "activities/revisions.rss.erb"
  end
  
  test "discussions" do
    get :discussions
    assert_response :success
    assert_template "activities/discussions"
  end
end
