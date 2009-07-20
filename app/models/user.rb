class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :revisions
  
  attr_readonly :login
  
  def to_param
    login
  end
  
  def created_pages
    revisions.ordered.all(:conditions => {:revision_number => 1}, :include => :page).map {|r| r.page }
  end
end
