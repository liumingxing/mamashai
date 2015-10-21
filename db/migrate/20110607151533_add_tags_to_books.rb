class AddTagsToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :tags, :string
  end

  def self.down
    remove_column :books, :tags
  end
end
