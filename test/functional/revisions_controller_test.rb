require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  test "show" do
    get :show, :page_id => pages(:sandbox).to_param, :id => revisions(:sandbox_b).to_param
    assert_response :success
  end
end
