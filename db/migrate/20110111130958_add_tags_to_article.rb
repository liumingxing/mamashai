class AddTagsToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :tags, :string, :limit=>200
  end

  def self.down
    remove_column :articles, :tags
  end
end
