require 'test_helper'

class IpsControllerTest < ActionController::TestCase
  def setup
    @ip = "0.0.0.0"
  end
  
  test "show" do
    get :show, :id => @ip
    assert_response :success
  end
  
  test "revisions" do
    @page = Factory(:page, :revision_attributes => {:remote_ip => @ip})
    2.times { Factory(:revision, :remote_ip => @ip, :page => @page) }
    
    get :revisions, :id => @ip
    assert_response :success
    assert_equal Revision.count(:conditions => {:remote_ip => @ip, :user_id => nil}), assigns(:revisions).length
  end
  
  test "discussions" do
    get :discussions, :id => @ip
    assert_response :success
  end
end
