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
    
    if @revision.last?
      redirect_to page_path(@page)
    end
  end
  
  def changes
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
    @previous_revision_body = @page.revisions.find_by_revision_number(@revision.revision_number - 1).try(:body) || ""
  end
  
  def content_age
    @page = Page.find_by_permalink!(params[:page_id])
    @revision = @page.revisions.find_by_revision_number!(params[:id])
    
    if !@revision.last?
      render :action => "content_age_with_revision_warning"
      return
    end
    
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.diff = @page.page_content_age_diff.data_as_objects
    visualizer.create_nodes
    visualizer.tag_age
    @nodes = visualizer.nodes
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
