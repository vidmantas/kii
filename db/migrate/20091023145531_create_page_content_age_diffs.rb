class CreatePageContentAgeDiffs < ActiveRecord::Migration
  def self.up
    create_table :page_content_age_diffs do |t|
      t.binary :data
      t.timestamps
    end
    
    add_column :pages, :page_content_age_diff_id, :integer
  end

  def self.down
    drop_table :page_content_age_diffs
    remove_column :pages, :page_content_age_diff_id
  end
end
