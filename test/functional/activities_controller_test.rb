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
  
  test "discussions" do
    get :discussions
    assert_response :success
    assert_template "activities/discussions"
  end
end
