require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  def setup
    @page = Factory(:page, :title => "Basic page")
    @discussion = Factory(:discussion, :page => @page)
  end
  
  test "index" do
    get :index, :page_id => @page.to_param
    assert_response :success
  end
  
  test "show" do
    get :show, :page_id => @page.to_param, :id => @discussion.to_param
    assert_response :success
  end
  
  test "new" do
    get :new, :page_id => @page.to_param
    assert_response :success
  end
  
  test "successful create" do
    assert_difference("Discussion.count") do
      assert_difference("DiscussionEntry.count") do
        post :create, :page_id => @page.to_param, :discussion => {
          :title => "Oy!",
          :discussion_entry_attributes => {:body => "Wazup?"}
        }
      end
    end
    
    assert_redirected_to page_discussion_path(@page, assigns(:discussion))
  end
  
  test "failed create" do
    post :create, :page_id => @page.to_param, :discussion => {
      :discussion_entry_attributes => {}
    }
    
    assert_response :success
    assert_template "discussions/new"
  end
  
  test "successful update" do
    assert_difference("DiscussionEntry.count") do
      put :update, :page_id => @page.to_param, :id => @discussion.to_param, :discussion => {
        :discussion_entry_attributes => {:body => "The second entry!"}
      }
    end
    
    assert_redirected_to page_discussion_path(@page, @discussion)
  end
  
  test "failed update" do
    put :update, :page_id => @page.to_param, :id => @discussion.to_param, :discussion => {
      :discussion_entry_attributes => {}
    }
    
    assert_response :success
    assert_template "discussions/show"
  end
end
