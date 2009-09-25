class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :revisions
  
  attr_readonly :login
  attr_accessible :login, :password, :password_confirmation, :profile_text
  
  def to_param
    login
  end
  
  def created_pages
    Page.created_by(self)
  end
end
