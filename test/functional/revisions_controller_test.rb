require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  test "show" do
    get :show, :page_id => pages(:sandbox).to_param, :id => revisions(:sandbox_b).to_param
    assert_response :success
  end
  
  test "changes with previous revision" do
    get :changes, :page_id => pages(:sandbox).to_param, :id => revisions(:sandbox_b).to_param
    assert_response :success
  end
  
  test "changes without previous revision" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :changes, :page_id => pages(:sandbox).to_param, :id => revisions(:sandbox_a).to_param
    end
  end
end
