class PagesController < ApplicationController
  before_filter :require_write_access, :except => [:index, :show]
  before_filter :require_admin, :only => [:destroy]
  before_filter :ensure_pretty_permalink, :only => [:show, :new]
  
  rescue_from ActiveRecord::StaleObjectError, :with => :handle_stale_page
  
  def to_homepage
    redirect_to page_path(Kii::CONFIG[:home_page])
  end
  
  def index
    @pages = Page.find(:all, :order => "title", :conditions => {:deleted => false})
  end
  
  def show
    @page = Page.find_by_permalink(params[:id])
    
    if @page
      if @page.deleted?
        render :action => "deleted"
      else
        render
      end
    else
      if Page.count(:conditions => {:permalink => params[:id].upcase_first_letter}) != 0
        redirect_to page_path(params[:id].upcase_first_letter)
      else
        @page = Page.new(:title => params[:id].from_permalink)
        render :action => "404"
      end
    end
  end
  
  def content_age
    @page = Page.find_by_permalink(params[:id])
    
    revisions = @page.revisions.all(:order => "revision_number ASC").map {|r| Kii::Diff::AgeVisualization::Revision.new(r.body, r.created_at)  }
    visualizer = Kii::Diff::AgeVisualization.new(revisions)
    visualizer.compute
    @nodes = visualizer.rev_out
  end
  
  def new
    @page = Page.new(:title => params[:id].from_permalink)
  end
  
  def create
    @page = Page.new(page_params_with_request_metadata)
    
    if used_preview_button?
      preview
    else
      @page.save!
      redirect_to page_path(@page)
    end
  end
  
  def edit
    @page = Page.find_by_permalink!(params[:id])
    @revision = @page.revisions.current.clone
    @revision.message = nil
  end
  
  def update
    @page = Page.find_by_permalink!(params[:id])
    @page.attributes = page_params_with_request_metadata
    
    if used_preview_button?
      preview
    else
      @page.save
      redirect_to page_path(@page)
    end
  end
  
  def confirm_destroy
    @page = Page.find_by_permalink!(params[:id])
  end
  
  def destroy
    @page = Page.find_by_permalink!(params[:id])
    @page.soft_destroy
    redirect_to page_path(@page)
  end
  
  private
  
  def used_preview_button?
    !params[:preview].blank?
  end
  
  def preview
    @revision = Revision.new(params[:page][:revision_attributes])
    
    if request.xhr?
      # Using render :inline is a bit tacky, but it saves us from creating a
      # separate view for this, or monving the helper into the application
      # controller.
      render :inline => "<%= render_body(@revision.body) %>"
    else
      render :action => "preview"
    end
  end
  
  def ensure_pretty_permalink
    if CGI.unescape(params[:id]).to_permalink != params[:id]
      redirect_to :id => params[:id].to_permalink
    end
  end

  def page_params_with_request_metadata
    params[:page][:revision_attributes].merge!({
      :remote_ip => request.remote_ip,
      :referrer => request.referrer,
      :user_id => current_user.try(:id)
    })
    
    return params[:page]
  end
  
  def handle_stale_page
    @revision = Revision.new(:body => params[:page][:revision_attributes][:body])
    @previous_revision = @page.revisions.find(@page.current_revision_id)
    @current_revision = @page.revisions.current
    
    @page.current_revision_id = @page.revisions.current.id
    render :action => "stale"
  end
end
