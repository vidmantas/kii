class Page < ActiveRecord::Base
  has_many :revisions, :dependent => :delete_all do
    def current
      ordered.first
    end
  end
  
  before_save :create_permalink, :bump_timestamps
  before_validation :build_revision
  before_validation_on_update :detect_stale_revision
  
  validates_presence_of :title, :revision_attributes
  validates_associated :revisions
  
  attr_accessor :revision_attributes
  
  def to_param
    permalink
  end
  
  attr_writer :current_revision_id
  def current_revision_id
    @current_revision_id ||= revisions.current.id
  end
  
  def soft_destroy
    ActiveRecord::Base.transaction do
      latest_revision = revisions.current.clone
      revisions.clear
      latest_revision.revision_number = 1
      latest_revision.send(:create_without_callbacks)
      
      self.deleted = true
      self.send(:update_without_callbacks)
    end
  end
  
  private
  
  def create_permalink
    self.permalink = self.title.to_permalink
  end
  
  # Saving a page normally involves creating a new revision, and leaving the
  # page itself unchanged. AR won't update the timestamps, so we force it to
  # here.
  def bump_timestamps
    self.updated_at = Time.now.utc
  end
  
  # We could have used the existing lock_version functionality, but since we
  # already have these revisions we can might as well use them to detect
  # staleness.
  def detect_stale_revision
    if current_revision_id.to_i != revisions.current.id
      raise ActiveRecord::StaleObjectError
    end
  end
  
  def build_revision
    r = revisions.build(revision_attributes)
  end
end
