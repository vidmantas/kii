class UsersController < ApplicationController
  before_filter :require_registration_enabled
  
  def show
    @user = User.find_by_login!(params[:id])
    @created_pages_count = @user.created_pages.count
    @created_revisions_count = @user.revisions.count
  end
  
  def revisions
    @user = User.find_by_login!(params[:id])
    @revisions = @user.revisions.find(:all, :order => "created_at DESC", :include => [:page, :user], :limit => 20)
  end
  
  def discussions
    @user = User.find_by_login!(params[:id])
    @discussions = Discussion.grouped_by_entries.by_user(@user).with_page.all(:limit => 20)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      UserSession.create(@user)
      redirect_to user_path(@user)
    else
      render :action => "new"
    end
  end
  
  private
  
  def require_registration_enabled
    redirect_to root_path unless Configuration[:public_registration]
  end
end
