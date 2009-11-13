require 'test_helper'

class RevisionsControllerTest < ActionController::TestCase
  def setup
    @page = Factory(:page, :title => "This is a page.")
    @revision = Factory(:revision, :page => @page)
  end
  
  test "index" do
    get :index, :page_id => @page.to_param
    assert_response :success
  end
  
  test "index rss" do
    get :index, :page_id => @page.to_param, :format => "rss"
    assert_response :success
  end
  
  test "show" do
    get :show, :page_id => @page.to_param, :id => @revision.to_param
    assert_response :success
  end
  
  test "showing older revision" do
    get :show, :id => 1, :page_id => @page.to_param
    assert_response :success
    assert_template "revisions/show"
  end
  
  test "changes" do
    get :changes, :id => @page.revisions.current.to_param, :page_id => @page.to_param
    assert_response :success
    assert_template "revisions/changes"
  end
  
  test "changest on first revision" do
    get :changes, :id => @page.revisions.first.to_param, :page_id => @page.to_param
    assert_response :success
    assert_template "revisions/changes"
  end
end
