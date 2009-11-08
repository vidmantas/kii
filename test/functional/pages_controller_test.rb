require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def setup
    Kii::CONFIG[:public_write] = true
    activate_authlogic
  end
  
  test "to_homepage" do
    get :to_homepage
    assert_response :redirect
  end
  
  test "index/all pages" do
    get :index
    assert_response :success
  end
  
  test "showing existing page" do
    get :show, :id => pages(:sandbox).to_param
    assert_response :success
    assert_template "pages/show"
  end
  
  test "showing none existing page" do
    get :show, :id => "Does Not Exist".to_permalink
    assert_response :success
    assert_template "pages/404"
  end
  
  test "showing downcased none existing page" do
    get :show, :id => "does not exist".to_permalink
    assert_response :success
    assert_template "pages/404"
    
    # It suggests both versions
    assert_select "a", "does not exist"
    assert_select "a", "Does not exist"
  end
  
  
  test "showing deleted page" do
    pages(:sandbox).soft_destroy
    get :show, :id => pages(:sandbox).to_param
    assert_response :success
    assert_template "pages/deleted"
  end
  
  test "new" do
    get :new, :id => "New Page".to_permalink
    assert_response :success
  end
  
  test "successful create" do
    ActionController::TestRequest.any_instance.expects(:remote_ip).returns("1.2.3.4").at_least_once
    ActionController::TestRequest.any_instance.expects(:referrer).returns("/testing").at_least_once
    
    assert_difference("Page.count") do
      post :create, :page => {
        :title => "New Page",
        :revision_attributes => {:body => "The body"}
      }
    end
    
    assert_redirected_to page_path("New Page".to_permalink)
    
    assert_equal "1.2.3.4", assigns(:page).revisions.current.remote_ip
    assert_equal "/testing", assigns(:page).revisions.current.referrer
    assert_equal nil, assigns(:page).revisions.current.user
  end
  
  test "successful create when logged in" do
    UserSession.create(users(:admin))
    
    assert_difference("Page.count") do
      post :create, :page => {
        :title => "New Page",
        :revision_attributes => {:body => "The body"}
      }
    end
    
    assert_equal users(:admin), assigns(:page).revisions.current.user
  end
  
  test "preview on create" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    assert_no_difference("Page.count") do
      post :create, :page => {
        :title => "New Page",
        :revision_attributes => {:body => "The body"}
      }
    end
    
    assert_equal "The body", assigns(:revision).body
    assert_response :success
    assert_template "pages/preview"
  end
  
  test "ajax preview on create" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    assert_no_difference("Page.count") do
      xhr :post, :create, :page => {
        :title => "New Page",
        :revision_attributes => {:body => "The body"}
      }
    end
    
    assert_response :success
    assert_template nil
  end
  
  test "edit" do
    get :edit, :id => pages(:sandbox).to_param
    assert_response :success
    assert_equal pages(:sandbox).revisions.current.body, assigns(:revision).body
    assert assigns(:revision).message.blank?
  end
  
  test "successful update" do
    ActionController::TestRequest.any_instance.expects(:remote_ip).returns("6.6.6.6").at_least_once
    ActionController::TestRequest.any_instance.expects(:referrer).returns("/foo").at_least_once
    
    post :update, :id => pages(:sandbox).to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal "6.6.6.6", assigns(:page).revisions.current.remote_ip
    assert_equal "/foo", assigns(:page).revisions.current.referrer
    assert_equal nil, assigns(:page).revisions.current.user
  end
  
  test "successful update when logged in" do
    UserSession.create(users(:admin))
    
    post :update, :id => pages(:sandbox).to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal users(:admin), assigns(:page).revisions.current.user
  end
  
  test "preview on update" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    post :update, :id => pages(:sandbox).to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal "A new body", assigns(:revision).body
    assert_response :success
    assert_template "pages/preview"
  end
  
  test "ajax preview on update" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    xhr :put, :update, :id => pages(:sandbox).to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_response :success
    assert_template nil
  end
  
  test "updating with no changes" do
    assert_no_difference("Revision.count") do
      post :update, :id => pages(:sandbox).to_param, :page => {
        :revision_attributes => {:body => pages(:sandbox).revisions.current.body}
      }
      
      assert_redirected_to page_path(pages(:sandbox))
    end
  end
  
  test "confirm destroy" do
    UserSession.create(users(:admin))
    
    get :confirm_destroy, :id => pages(:sandbox).to_param
    assert_response :success
  end
  
  test "destroying" do
    UserSession.create(users(:admin))
    delete :destroy, :id => pages(:sandbox).to_param
    assert_redirected_to page_path(pages(:sandbox))
    assert pages(:sandbox).reload.deleted?
  end
  
  test "pretty permalinks" do
    get :show, :id => "Not a pretty permalink"
    assert_redirected_to page_path("Not a pretty permalink".to_permalink)
    
    get :new, :id => "Not so pretty either"
    assert_redirected_to new_page_path("Not so pretty either".to_permalink)
  end
  
  test "redirect to upcased version if downcased version does not exist" do
    get :show, :id => pages(:iphone).to_param
    assert_response :success, "Upcased artile does not exist, so no redirect here."
    
    get :show, :id => pages(:home).to_param.downcase
    assert_redirected_to page_path(pages(:home)), "Upcased article exist, redirect."
  end
  
  test "without write access" do
    Kii::CONFIG[:public_write] = false
    assert_raises(ApplicationController::LacksWriteAccess) {
      get :new, :id => "New Page".to_permalink
    }
  end
  
  test "a page full of stuff" do
    get :show, :id => pages(:bloated).to_param
    assert_response :success
    
    assert_select "a.pagelink.exists", "Existing page"
    
    assert_select "a.pagelink.exists", "Sandbox"
    assert_select "a.pagelink.exists", "sandbox"

    assert_select "a.pagelink.exists", "iPhone"
    assert_select "a.pagelink.void", "IPhone"
    assert_select "a.pagelink.exists", "IPHONE"
  end

  test "stale edits" do
    post :update, :id => pages(:sandbox).to_param, :page => {
      :current_revision_id => revisions(:sandbox_a).id,
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_response :success
    assert_template "pages/stale"
  end
  
  test "content age" do
    get :content_age, :id => pages(:sandbox).to_param
    assert_response :success
    assert_template "pages/content_age"
  end
end
