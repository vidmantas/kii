require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  test "index" do
    get :index, :page_id => pages(:sandbox).to_param
    assert_response :success
  end
  
  test "show" do
    get :show, :page_id => pages(:sandbox).to_param, :id => revisions(:sandbox_b).to_param
    assert_response :success
  end
  
  test "showing current revision" do
    get :show, :id => pages(:sandbox).revisions.current.to_param, :page_id => pages(:sandbox).to_param
    assert_redirected_to page_path(pages(:sandbox))
  end
  
  test "showing older revision" do
    get :show, :id => 1, :page_id => pages(:sandbox).to_param
    assert_response :success
    assert_template "revisions/show"
  end
  
  test "changes" do
    get :changes, :id => pages(:sandbox).revisions.current.to_param, :page_id => pages(:sandbox).to_param
    assert_response :success
    assert_template "revisions/changes"
  end
  
  test "changest on first revision" do
    get :changes, :id => revisions(:sandbox_a).to_param, :page_id => pages(:sandbox).to_param
    assert_response :success
    assert_template "revisions/changes"
  end
  
  test "content age on newest revision" do
    get :content_age, :id => pages(:sandbox).revisions.current.to_param, :page_id => pages(:sandbox).to_param
    assert_response :success
    assert_template "revisions/content_age"
  end
  
  test "content age on older revision" do
    get :content_age, :id => 1, :page_id => pages(:sandbox).to_param
    assert_response :success
    assert_template "revisions/content_age_with_revision_warning"
  end
end
