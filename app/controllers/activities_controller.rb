class ActivitiesController < ApplicationController
  def index
    redirect_to revisions_activities_path
  end
  
  def revisions
    @revisions = Revision.find(:all, :order => "created_at DESC", :limit => 50, :include => [:page, :user])
  end
  
  def discussions
    @discussions = Discussion.with_page.with_latest_discussion_entry.ordered.all(:limit => 50)
  end
end
