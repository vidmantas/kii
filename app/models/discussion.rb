class Discussion < ActiveRecord::Base
  belongs_to :page
  has_many :discussion_entries
  
  # Using this instead of a named scope so that it can be refered to in find(:all, :include => ..).
  has_one :latest_discussion_entry, :class_name => "DiscussionEntry", :foreign_key => "discussion_id", :order => "created_at DESC"
  
  named_scope :grouped_by_entries, :joins => :discussion_entries, :include => :page, :group => "discussions.id, #{columns_with_table_name}"
  named_scope :by_user, lambda {|user| {:conditions => ["discussion_entries.user_id = ?", user.id]} }
  named_scope :by_ip, lambda {|ip| {:conditions => ["discussion_entries.user_id IS ? AND discussion_entries.remote_ip = ?", nil, ip]} }
  
  validates_presence_of :title, :page_id

  attr_accessor :discussion_entry_attributes
  attr_reader :new_discussion_entry
  before_validation :build_discussion_entry
  before_save :bump_timestamps
  validate :require_valid_discussion_entry
  
  def replies_count
    discussion_entries_count - 1
  end
  
  private
  
  def build_discussion_entry
    @new_discussion_entry = discussion_entries.build(discussion_entry_attributes)
  end
  
  def require_valid_discussion_entry
    errors.add_to_base("Discussion entry is invalid") unless new_discussion_entry.valid?
  end
  
  # Bump timestamps whenever, regardless of the record not having changed.
  def bump_timestamps
    self.updated_at = Time.now
  end
end
