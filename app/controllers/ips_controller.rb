class IpsController < ApplicationController
  def show
    @ip = params[:id]
    #@created_pages = Page.by_ip(@ip).all(:limit => 20)
  end
  
  def revisions
    @ip = params[:id]
    @revisions = Revision.all(:conditions => {:user_id => nil, :remote_ip => @ip}, :include => [:page], :limit => 20)
  end
  
  def discussions
    @ip = params[:id]
    @discussions = Discussion.grouped_by_entries.by_ip(@ip).with_page.all(:limit => 20)
  end
end
