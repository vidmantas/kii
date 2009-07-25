class DiscussionEntry < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :user
  
  before_create :cache_at_revision
  
  validates_presence_of :body
  
  private
  
  def cache_at_revision
    self.at_revision = discussion.page.revisions.current.revision_number
  end
end
