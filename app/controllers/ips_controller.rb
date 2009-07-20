class IpsController < ApplicationController
  def show
    @ip = params[:id]
    @revisions = Revision.all(:conditions => {:remote_ip => @ip}, :include => [:page])
  end
end
