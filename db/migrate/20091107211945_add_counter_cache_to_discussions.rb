class AddCounterCacheToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions, :discussion_entries_count, :integer
  end

  def self.down
    remove_column :discussions, :discussion_entries_count
  end
end
