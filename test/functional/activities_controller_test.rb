require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
  end
end
