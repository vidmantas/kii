class Page < ActiveRecord::Base
  RESTRICTED_NAMES = ["_"]

  has_many :discussions, :dependent => :destroy
  has_many :revisions, :dependent => :delete_all do
    def current
      ordered.first
    end
  end
  belongs_to :page_content_age_diff
  
  before_save :create_permalink, :bump_timestamps
  after_create :create_page_content_age_diff
  after_update :update_page_content_age_diff
  before_validation :build_revision
  
  validates_presence_of :title, :revision_attributes
  validates_associated :revisions
  validate :validate_restricted_names
  validate_on_update :validate_changes_occurred
  
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
  
  # The body of the page is stored in the revision. `revision_attributes` is a
  # hash that will be used when creating the new Revision instance on page save
  # and update.
  attr_accessor :revision_attributes
  
  def to_param
    permalink
  end
  
  # `destroy` is never called. `soft_destroy` will delete all revisions
  # except the current, and set the deleted attribute to true.
  def soft_destroy
    return if home_page?
    
    ActiveRecord::Base.transaction do
      # Make latest revision current, delete all others
      latest_revision = revisions.current.clone
      revisions.destroy_all
      latest_revision.revision_number = 1
      latest_revision.instance_eval { create_without_callbacks } # private method
      
      reprocess_page_content_age_diff
      
      discussions.destroy_all
      
      self.deleted = true
      update_without_callbacks
    end
  end
  def destroy; end
  
  def restore
    return unless deleted?
    
    self.deleted = false
    update_without_callbacks
  end
  
  def rollback_to(revision)
    ActiveRecord::Base.transaction do
      Revision.delete_all(["revision_number > ? AND page_id = ?", revision.revision_number, self.id])
      reprocess_page_content_age_diff
    end
  end
  
  def home_page?
    self.permalink == Configuration[:home_page]
  end
  
  private
  
  def create_permalink
    self.permalink = self.title.to_permalink
  end
  
  # Updating a page doesn't alter the page record at all (a new Revision is
  # created instead), but we want updated_at to change.
  def bump_timestamps
    self.updated_at = Time.now.utc
  end
  
  def build_revision
    @new_revision = revisions.build(revision_attributes)
  end
  
  def validate_changes_occurred
    if @new_revision.body == revisions.current.body
      errors.add_to_base("No changes were made")
    end
  end
  
  def validate_restricted_names
    errors.add("title", "is restricted") if RESTRICTED_NAMES.include?(title)
  end
  
  def create_page_content_age_diff
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.revisions = [Kii::Diff::AgeVisualization::Revision.new(@new_revision.body, @new_revision.created_at)]
    visualizer.create_diff_from_revisions
    
    self.page_content_age_diff = PageContentAgeDiff.create!(:data_as_objects => visualizer.diff)
    update_without_callbacks
  end
  
  def update_page_content_age_diff
    record = self.page_content_age_diff
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.create_diff_manually(record.data_as_objects, Kii::Diff::AgeVisualization::Revision.new(@new_revision.body, @new_revision.created_at))
    
    record.update_attribute(:data_as_objects, visualizer.diff)
  end
  
  def reprocess_page_content_age_diff
    first_revision = revisions.find_by_revision_number(1)
    newest_revision = revisions.current
    
    visualizer = Kii::Diff::AgeVisualization.new
    visualizer.revisions = [
      Kii::Diff::AgeVisualization::Revision.new(first_revision.body, first_revision.created_at),
      Kii::Diff::AgeVisualization::Revision.new(newest_revision.body, newest_revision.created_at)
    ]
    visualizer.create_diff_from_revisions
    
    self.page_content_age_diff = PageContentAgeDiff.create!(:data_as_objects => visualizer.diff)
    update_without_callbacks
  end
end
