class DiscussionsController < ApplicationController
  def index
    @general_discussions = Discussion.find(:all, :include => [:latest_discussion_entry], :order => "discussion_entries.updated_at DESC", :conditions => ["page_id IS ?", nil], :limit => 10)
    @page_discussions = Discussion.find(:all, :include => [:latest_discussion_entry, :page], :order => "discussion_entries.updated_at DESC", :conditions => ["page_id IS NOT ?", nil], :limit => 10)
  end
  
  def show
    @discussion = Discussion.find(params[:id])
    @page = @discussion.page
  end
end
