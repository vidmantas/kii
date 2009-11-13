class AddLockVersionToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :lock_version, :integer, :default => 0
    Page.update_all :lock_version => 0
  end

  def self.down
    remove_column :pages, :lock_version
  end
end
