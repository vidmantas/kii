class DiscussionsController < ApplicationController
  def index
    @page = Page.find_by_permalink!(params[:page_id])
    @discussions = @page.discussions.all(:include => {:latest_discussion_entry => :user}, :order => "updated_at DESC")
  end
  
  def show
    @page = Page.find_by_permalink!(params[:page_id])
    @discussion = @page.discussions.find(params[:id])
    @discussion_entries = @discussion.discussion_entries.all(:include => [:user], :order => "created_at ASC")
    
    @discussion_entry = DiscussionEntry.new
  end
  
  def new
    @page = Page.find_by_permalink!(params[:page_id])
    @discussion = @page.discussions.new
    @discussion_entry = DiscussionEntry.new
  end
  
  def create
    @page = Page.find_by_permalink!(params[:page_id])
    @discussion = @page.discussions.new(discussion_params_with_request_metadata)
    
    if @discussion.save
      redirect_to page_discussion_path(@page, @discussion)
    else
      render :action => "new"
    end
  end
  
  def update
    @page = Page.find_by_permalink!(params[:page_id])
    @discussion = @page.discussions.find(params[:id])

    if @discussion.update_attributes(discussion_params_with_request_metadata)
      redirect_to page_discussion_path(@page, @discussion)
    else
      @discussion_entries = @discussion.discussion_entries.all(:include => [:user])
      render :action => "show"
    end
  end
  
  private
  
  def discussion_params_with_request_metadata
    params[:discussion][:discussion_entry_attributes].merge!({
      :remote_ip => request.remote_ip,
      :referrer => request.referrer,
      :user => current_user
    })
    
    return params[:discussion]
  end
end
