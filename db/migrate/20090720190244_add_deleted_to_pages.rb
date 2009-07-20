class AddDeletedToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :deleted, :boolean, :default => false
    Page.update_all(:deleted => false)
  end

  def self.down
    remove_column :pages, :deleted
  end
end
