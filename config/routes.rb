ActionController::Routing::Routes.draw do |map|
  map.root :controller => "pages", :action => "to_homepage", :conditions => {:method => :get}
  
  # Everything that isn't page related gets a prefix, so that we don't get
  # conflicting page names and internal routes.
  map.with_options :path_prefix => "_" do |m|
    m.resource :search, :only => [:show]
    m.resource :profile, :only => [:edit, :update]
    m.resource :session
    m.logout 'logout', :controller => "sessions", :action => "destroy"
    m.resources :users
    m.resources :ips, :only => [:show], :requirements => {:id => /.+/} # allowing dots in the :id.
    
    m.resources :activities, :only => [:index]
  end
  
  # Can't do map.resources here, since we want /foo, not /pages/foo.
  map.with_options :controller => "pages" do |m|
    m.all_pages "all_pages", :path_prefix => "_", :action => "index"
    
    m.new_page "new/:id", :action => "new",  :conditions => {:method => :get}
    m.edit_page ":id/edit", :action => "edit",  :conditions => {:method => :get}
    
    m.pages "", :action => "create",            :conditions => {:method => :post}

    m.connect ":id", :action => "update", :conditions => {:method => :put}
    
    m.confirm_destroy_page ":id/confirm_destroy", :action => "confirm_destroy", :conditions => {:method => :get}
    m.connect ":id", :action => "destroy", :conditions => {:method => :delete}
  end
  
  map.with_options :controller => "revisions", :path_prefix => ":page_id" do |m|
    m.page_revisions "revisions", :action => "index",     :conditions => {:method => :get}
    m.page_revision "revisions/:id", :action => "show",   :conditions => {:method => :get}
    m.page_revision_changes "revisions/:id/changes", :action => "changes", :conditions => {:method => :get}
    m.confirm_destroy_page_revision "revisions/:id/confirm_destroy", :action => "confirm_destroy", :conditions => {:method => :get}
    m.connect "revisions/:id", :action => "destroy", :conditions => {:method => :delete}
  end  
  
  # At the lowest priority, we have the catch all page route. It has to be at the bottom because of
  # the :requirements regex.
  map.page ":id", :controller => "pages", :action => "show", :conditions => {:method => :get}, :requirements => {:id => /.+/}
end
