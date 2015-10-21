class AddColumnContentToArticleComments < ActiveRecord::Migration
  def self.up
    add_column :article_comments, :content, :string, :limit => 210
  end

  def self.down
    remove_column :article_comments, :content
  end
end
