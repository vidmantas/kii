class RevisionsController < ApplicationController
  def index
    @page = Page.find_by_permalink!(params[:page_id])
    @revisions = @page.revisions.ordered.with_user
  end
  
  def show
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number(params[:id])
  end
  
  def changes
    @page = Page.find_by_permalink!(params[:page_id])
    @current_revision = @page.revisions.find_by_revision_number!(params[:id])
    @previous_revision = @page.revisions.find_by_revision_number!(@current_revision.revision_number - 1)
  end
  
  def confirm_revert
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number(params[:id])
  end
end
