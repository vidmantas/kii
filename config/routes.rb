# This file is a freaking mess because of pages being on / instead of the default /pages.
# Will fix when 3.0 ships, when the routing code in Rails stops being poop.
ActionController::Routing::Routes.draw do |map|
  map.root :controller => "pages", :action => "to_homepage", :conditions => {:method => :get}
  
  # Everything that isn't page related gets a prefix, so that we don't get
  # conflicting page names and internal routes.
  map.with_options :path_prefix => "_" do |m|
    m.resource :search, :only => [:show]
    m.resource :profile,
      :only => [:edit, :update]
    m.resource :session
    m.logout 'logout', :controller => "sessions", :action => "destroy"
    m.resources :users,
      :only => [:show, :new, :create],
      :member => {:revisions => :get, :discussions => :get}
    m.resources :ips, 
      :only => [:show],
      :member => {:revisions => :get, :discussions => :get},
      :requirements => {:id => /.+/} # allowing dots in the :id.
    
    m.resources :activities,
      :only => [:index],
      :collection => {:revisions => :get, :others_revisions => :get, :discussions => :get}
  end
  
  # Can't do map.resources here, since we want /foo, not /pages/foo.
  map.with_options :controller => "pages" do |m|
    m.with_options :path_prefix => "_" do |p|
      p.with_options :conditions => {:method => :get} do |get|
        get.all_pages "all_pages", :action => "index"
        get.new_page "new/:id", :action => "new"
        get.edit_page ":id/edit", :action => "edit"
        get.confirm_destroy_page ":id/confirm_destroy", :action => "confirm_destroy"
        get.content_age_page ":id/content_age", :action => "content_age"
      end
      
      p.restore_page ":id",
        :action => "restore",
        :conditions => {:method => :post}
    end

    m.pages "", :action => "create", :conditions => {:method => :post}
    m.connect ":id", :action => "update", :conditions => {:method => :put}
    m.connect ":id", :action => "destroy", :conditions => {:method => :delete}
  end
  
  map.with_options :path_prefix => "_/:page_id", :name_prefix => "page_" do |page|
    page.resources :revisions,
      :member => {:changes => :get, :confirm_rollback => :get, :rollback => :post},
      :only => [:index, :show]
    
    page.resources :discussions do |discussion|
      discussion.resources :discussion_entries,
        :only => [:create]
    end
  end

  # At the lowest priority, we have the catch all page route. It has to be at the bottom because of
  # the :requirements regex.
  map.page ":id",
    :controller => "pages",
    :action => "show",
    :conditions => {:method => :get},
    :requirements => {:id => /.+/}
end
