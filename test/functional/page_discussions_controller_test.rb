require 'test_helper'

class PageDiscussionsControllerTest < ActionController::TestCase
  test "index" do
    get :index, :page_id => pages(:sandbox).to_param
    assert_response :success
  end
  
  test "show" do
    get :show, :page_id => pages(:sandbox).to_param, :id => discussions(:sandbox_a)
    assert_response :success
  end
  
  test "new" do
    get :new, :page_id => pages(:sandbox).to_param
    assert_response :success
  end
  
  test "successful create" do
    assert_difference("Discussion.count") do
      assert_difference("DiscussionEntry.count") do
        post :create, :page_id => pages(:sandbox).to_param, :discussion => {
          :title => "Oy!",
          :discussion_entry_attributes => {:body => "Wazup?"}
        }
      end
    end
    
    assert_redirected_to page_discussion_path(pages(:sandbox), assigns(:discussion))
  end
  
  test "failed create" do
    post :create, :page_id => pages(:sandbox).to_param, :discussion => {
      :discussion_entry_attributes => {}
    }
    
    assert_response :success
    assert_template "discussions/new"
  end
  
  test "successful update" do
    assert_difference("DiscussionEntry.count") do
      put :update, :page_id => pages(:sandbox).to_param, :id => discussions(:sandbox_a).to_param, :discussion => {
        :discussion_entry_attributes => {:body => "The second entry!"}
      }
    end
    
    assert_redirected_to page_discussion_path(pages(:sandbox), discussions(:sandbox_a))
  end
  
  test "failed update" do
    put :update, :page_id => pages(:sandbox).to_param, :id => discussions(:sandbox_a).to_param, :discussion => {
      :discussion_entry_attributes => {}
    }
    
    assert_response :success
    assert_template "discussions/show"
  end
end
