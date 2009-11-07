class DiscussionEntry < ActiveRecord::Base
  belongs_to :discussion, :counter_cache => true
  belongs_to :user
  
  before_create :cache_at_revision
  
  validates_presence_of :body, :referrer, :remote_ip
  
  private
  
  def cache_at_revision
    self.at_revision = discussion.page.revisions.current.revision_number
  end
end
