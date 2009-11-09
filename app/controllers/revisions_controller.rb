class RevisionsController < ApplicationController
  before_filter :require_admin, :only => [:confirm_revert, :revert]
  
  def index
    @page = Page.find_by_permalink!(params[:page_id])
    @revisions = @page.revisions.ordered.with_user
    @revision = @revisions[0]
    
    @rss = url_for(:format => "rss")
  end
  
  def show
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
  end
  
  def changes
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
    @previous_revision_body = @page.revisions.find_by_revision_number(@revision.revision_number - 1).try(:body) || ""
  end
  
  def confirm_rollback
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
  end
  
  def rollback
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
    @page.rollback_to(@revision)
    
    flash[:success] = "Successfully rolled page back to revision \##{@revision.revision_number}"
    redirect_to page_path(@page)
  end
end
