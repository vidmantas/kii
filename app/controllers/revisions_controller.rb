class RevisionsController < ApplicationController
  before_filter :require_admin, :only => [:confirm_revert, :revert]
  
  def index
    @page = Page.find_by_permalink!(params[:page_id])
    @revisions = @page.revisions.ordered.with_user
    @revision = @revisions[0]
  end
  
  def show
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
  end
  
  def confirm_destroy
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
  end
  
  def destroy
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
    @revision.destroy
    
    flash[:success] = "Revision \##{@revision.revision_number} was successfully reverted"
    redirect_to page_path(@page)
  end
end
