class IpsController < ApplicationController
  def show
    @ip = params[:id]
    @revisions = Revision.all(:conditions => {:user_id => nil, :remote_ip => @ip}, :include => [:page])
    @created_pages = Page.by_ip(@ip)
    @discussions = Discussion.all(:joins => :discussion_entries, :include => :page, :conditions => ["discussion_entries.user_id IS ? AND discussion_entries.remote_ip = ?", nil, @ip])
  end
end
