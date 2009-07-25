class CreateDiscussionEntries < ActiveRecord::Migration
  def self.up
    create_table :discussion_entries do |t|
      t.text :body
      t.string :remote_ip, :referrer
      t.integer :user_id, :discussion_id
      t.integer :at_revision
      t.timestamps
    end
    
    add_index :discussion_entries, :discussion_id
  end

  def self.down
    drop_table :discussion_entries
  end
end
