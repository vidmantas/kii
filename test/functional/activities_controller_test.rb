require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
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
    get :others_revisions, :id => users(:admin).id
    assert_response :success
    assert_template "activities/others_revisions"
  end
  
  test "others revision rss" do
    get :others_revisions, :id => users(:admin).id, :format => "rss"
    assert_response :success
    assert_template "activities/revisions.rss.erb"
  end
  
  test "discussions" do
    get :discussions
    assert_response :success
    assert_template "activities/discussions"
  end
end
