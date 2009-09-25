class Page < ActiveRecord::Base
  class NoChangesError < RuntimeError; end
  RESTRICTED_NAMES = ["_"]

  has_many :discussions, :dependent => :destroy
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
  validate :avoid_restricted_names
  validate_on_update :disallow_unchanged_updates
  
  named_scope :by_user, lambda {|user| {
    :joins => :revisions, :group => "pages.id, #{columns_with_table_name}",
    :select => "#{columns_with_table_name}",
    :conditions => ["revisions.revision_number = ? AND revisions.user_id = ?", 1, user.id]
  }}
  
  named_scope :by_ip, lambda {|ip| {
    :joins => :revisions, :group => "pages.id, #{columns_with_table_name}",
    :select => "#{columns_with_table_name}",
    :conditions => ["revisions.revision_number = ? AND revisions.user_id IS ? AND revisions.remote_ip = ?", 1, nil, ip]
  }}
  
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
      # Remove all revisions, create a copy of the most recent revision and
      # store it as revision 1
      latest_revision = revisions.current.clone
      revisions.clear
      latest_revision.revision_number = 1
      latest_revision.send(:create_without_callbacks)
      
      # Set to deleted without running callbacks or validations
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
  
  def disallow_unchanged_updates
    if @new_revision.body == revisions.current.body
      errors.add_to_base("No changes were made")
    end
  end
  
  def build_revision
    @new_revision = revisions.build(revision_attributes)
  end
  
  def avoid_restricted_names
    errors.add("title", "is restricted") if RESTRICTED_NAMES.include?(title)
  end
end
