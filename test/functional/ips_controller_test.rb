require 'test_helper'

class IpsControllerTest < ActionController::TestCase
  test "show" do
    get :show, :id => "0.0.0.0"
    assert_response :success
    assert !assigns(:revisions).blank?
    assert_equal Revision.count(:conditions => {:remote_ip => "0.0.0.0"}), assigns(:revisions).length
  end
end
