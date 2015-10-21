class RenameTagsToTagsNameForBooks < ActiveRecord::Migration
  def self.up
    rename_column :books, :tags, :tag_names
  end

  def self.down
    rename_column :books, :tag_names, :tags
  end
end
