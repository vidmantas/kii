require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  def setup
    Kii::CONFIG[:public_write] = true
    activate_authlogic
    @page = Factory(:page)
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
    get :show, :id => @page.to_param
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
    @page.soft_destroy
    get :show, :id => @page.to_param
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
    @user = Factory(:user, :admin => true)
    UserSession.create(@user)
    
    assert_difference("Page.count") do
      post :create, :page => {
        :title => "New Page",
        :revision_attributes => {:body => "The body"}
      }
    end
    
    assert_equal @user, assigns(:page).revisions.current.user
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
    get :edit, :id => @page.to_param
    assert_response :success
    assert_equal @page.revisions.current.body, assigns(:revision).body
    assert assigns(:revision).message.blank?
  end
  
  test "successful update" do
    ActionController::TestRequest.any_instance.expects(:remote_ip).returns("6.6.6.6").at_least_once
    ActionController::TestRequest.any_instance.expects(:referrer).returns("/foo").at_least_once
    
    post :update, :id => @page.to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal "6.6.6.6", assigns(:page).revisions.current.remote_ip
    assert_equal "/foo", assigns(:page).revisions.current.referrer
    assert_equal nil, assigns(:page).revisions.current.user
  end
  
  test "successful update when logged in" do
    @user = Factory(:user, :admin => true)
    UserSession.create(@user)
    
    post :update, :id => @page.to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal @user, assigns(:page).revisions.current.user
  end
  
  test "preview on update" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    post :update, :id => @page.to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_equal "A new body", assigns(:revision).body
    assert_response :success
    assert_template "pages/preview"
  end
  
  test "ajax preview on update" do
    PagesController.any_instance.expects(:used_preview_button?).returns(true)
    
    xhr :put, :update, :id => @page.to_param, :page => {
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_response :success
    assert_template nil
  end
  
  test "updating with no changes" do
    assert_no_difference("Revision.count") do
      post :update, :id => @page.to_param, :page => {
        :revision_attributes => {:body => @page.revisions.current.body}
      }
      
      assert_redirected_to page_path(@page)
    end
  end
  
  test "restore" do
    @page.soft_destroy
    assert @page.deleted?
    
    post :restore, :id => @page.to_param
    assert_redirected_to page_path(@page)
    @page.reload
    assert !@page.deleted?
  end
  
  test "confirm destroy" do
    UserSession.create(Factory(:user, :admin => true))
    
    get :confirm_destroy, :id => @page.to_param
    assert_response :success
  end
  
  test "destroying" do
    UserSession.create(Factory(:user, :admin => true))
    delete :destroy, :id => @page.to_param
    assert_redirected_to page_path(@page)
    assert @page.reload.deleted?
  end
  
  test "pretty permalinks" do
    get :show, :id => "Not a pretty permalink"
    assert_redirected_to page_path("Not a pretty permalink".to_permalink)
    
    get :new, :id => "Not so pretty either"
    assert_redirected_to new_page_path("Not so pretty either".to_permalink)
  end
  
  test "redirect to upcased version if downcased version does not exist" do
    get :show, :id => Factory(:page, :title => "iPhone").to_param
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
    page_contents = <<-EOF
This page has a lot of stuff in it. Its purpose is to cause a test to fail if there are any errors in `Kii::Markup`.

Let's start with a [[home|Existing page]]. Now for a page that [[does not exist]].

[[Sandbox]] and [[sandbox]].

[[iPhone]], [[IPhone]] and [[IPHONE]].
    EOF
    
    Factory(:page, :title => "Sandbox")
    Factory(:page, :title => "iPhone")
    Factory(:page, :title => "IPHONE")
    
    get :show, :id => Factory(:page, :title => "Bloated", :revision_attributes => {:body => page_contents}).to_param
    assert_response :success
    
    assert_select "a.pagelink.exists", "Existing page"
    
    assert_select "a.pagelink.exists", "Sandbox"
    assert_select "a.pagelink.exists", "sandbox"

    assert_select "a.pagelink.exists", "iPhone"
    assert_select "a.pagelink.void", "IPhone"
    assert_select "a.pagelink.exists", "IPHONE"
  end

  test "stale edits" do
    page = Factory(:page, :title => "Mr. Stale")
    revision = Factory(:revision, :page => page)
    3.times { Factory(:revision, :page => page) }
    
    post :update, :id => page.to_param, :page => {
      :lock_version => 0,
      :revision_attributes => {:body => "A new body"}
    }
    
    assert_response :success
    assert_template "pages/stale"
  end
  
  test "content age" do
    get :content_age, :id => @page.to_param
    assert_response :success
    assert_template "pages/content_age"
  end
end
