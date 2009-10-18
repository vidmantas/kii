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
    m.resources :discussions
    
    m.resources :activities, :only => [:index]
  end
  
  # Can't do map.resources here, since we want /foo, not /pages/foo.
  map.with_options :controller => "pages" do |m|
    m.with_options :conditions => {:method => :get} do |get|
      get.all_pages "all_pages", :path_prefix => "_", :action => "index"
      get.new_page "new/:id", :action => "new"
      get.edit_page ":id/edit", :action => "edit"
      get.page_content_age ":id/content_age", :action => "content_age"
      get.confirm_destroy_page ":id/confirm_destroy", :action => "confirm_destroy"
    end

    m.pages "", :action => "create", :conditions => {:method => :post}
    m.connect ":id", :action => "update", :conditions => {:method => :put}
    m.connect ":id", :action => "destroy", :conditions => {:method => :delete}

  end
  
  # Since we don't have a map.resources for pages (see above), we route page
  # sub controllers manually as well.
  map.with_options :path_prefix => ":page_id", :name_prefix => "page_" do |page|
    page.with_options :controller => "revisions" do |r|
      r.with_options :conditions => {:method => :get} do |get|
        get.revisions "revisions", :action => "index"
        get.revision "revisions/:id", :action => "show"
        get.revision_changes "revisions/:id/changes", :action => "changes"
        get.confirm_destroy_revision "revisions/:id/confirm_destroy", :action => "confirm_destroy"
      end
      
      r.connect "revisions/:id", :action => "destroy", :conditions => {:method => :delete}
    end
    
    page.with_options :controller => "page_discussions" do |d|
      d.with_options :conditions => {:method => :get} do |get|
        get.discussions "discussions", :action => "index"
        get.discussion "discussions/new", :action => "new", :name_prefix => "new_page_"
        get.discussion "discussions/:id", :action => "show"
      end
      
      d.connect "discussions", :action => "create", :conditions => {:method => :post}
      d.connect "discussions/:id", :action => "update", :conditions => {:method => :put}
    end
    
    page.with_options :controller => "discussion_entries" do |d|
      d.discussion_discussion_entries "discussions/:id/discussion_entries", :conditions => {:method => :post}
    end
  end

  # At the lowest priority, we have the catch all page route. It has to be at the bottom because of
  # the :requirements regex.
  map.page ":id", :controller => "pages", :action => "show", :conditions => {:method => :get}, :requirements => {:id => /.+/}
end
