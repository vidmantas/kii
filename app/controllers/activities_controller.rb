class ActivitiesController < ApplicationController
  def index
    redirect_to revisions_activities_path
  end
  
  def revisions
    @revisions = Revision.find(:all, :order => "created_at DESC", :limit => 50, :include => [:page, :user])
    @rss = url_for(:format => "rss")
    
    respond_to do |format|
      format.html
      format.rss
    end
  end
  
  # Using params[:id] because the RSS reader won't be logged in. Exposing the ID isn't a problem, hopefully.
  def others_revisions
    @revisions = Revision.find(:all, :order => "created_at DESC", :limit => 50, :include => [:page, :user], :conditions => ["user_id != ? OR user_id IS ?", params[:id], nil])
    @rss = url_for(:format => "rss", :id => params[:id])
    
    respond_to do |format|
      format.html
      format.rss { render :action => "revisions" }
    end
  end
  
  def discussions
    @discussions = Discussion.with_page.with_latest_discussion_entry.ordered.all(:limit => 50)
  end
end
