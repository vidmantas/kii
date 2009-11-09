class Page < ActiveRecord::Base
  class NoChangesError < RuntimeError; end
  RESTRICTED_NAMES = ["_"]

  has_many :discussions, :dependent => :destroy
  has_many :revisions, :dependent => :delete_all do
    def current
      ordered.first
    end
  end
  belongs_to :page_content_age_diff
  
  before_save :create_permalink, :bump_timestamps
  after_save :unset_current_revision_id
  after_create :create_page_content_age_diff
  after_update :update_page_content_age_diff
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
    return if home_page?
    
    ActiveRecord::Base.transaction do
      # Remove all revisions, create a copy of the most recent revision and
      # store it as revision 1
      latest_revision = revisions.current.clone
      revisions.clear
      latest_revision.revision_number = 1
      latest_revision.send(:create_without_callbacks)
      
      # Remove discussions
      discussions.destroy_all
      
      # Set to deleted without running callbacks or validations
      self.deleted = true
      self.send(:update_without_callbacks)
    end
  end
  
  def rollback_to(revision)
    Revision.delete_all(["revision_number > ? AND page_id = ?", revision.revision_number, self.id])
  end
  
  def home_page?
    self.title == Kii::CONFIG[:home_page]
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
  
  def unset_current_revision_id
    @current_revision_id = nil
  end
  
  def create_page_content_age_diff
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.revisions = [Kii::Diff::AgeVisualization::Revision.new(@new_revision.body, @new_revision.created_at)]
    visualizer.create_diff_from_revisions
    
    self.page_content_age_diff = PageContentAgeDiff.create!(:data_as_objects => visualizer.diff)
    self.send(:update_without_callbacks)
  end
  
  def update_page_content_age_diff
    obj = self.page_content_age_diff
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.create_diff_manually(obj.data_as_objects, Kii::Diff::AgeVisualization::Revision.new(@new_revision.body, @new_revision.created_at))
    
    obj.update_attribute(:data_as_objects, visualizer.diff)
  end
end
