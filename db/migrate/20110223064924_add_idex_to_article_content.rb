class AddIdexToArticleContent < ActiveRecord::Migration
  def self.up
    add_index :article_contents, :content, :fulltext
    add_index :article_contents, :article_id, :unique=>true
  end

  def self.down
  end
end
