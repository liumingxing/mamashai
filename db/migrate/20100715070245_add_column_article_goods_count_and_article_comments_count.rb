class AddColumnArticleGoodsCountAndArticleCommentsCount < ActiveRecord::Migration
  def self.up
    add_column :articles, :article_goods_count, :integer, :default => 0
    add_column :articles, :article_comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :articles, :article_goods_count
    remove_column :articles, :article_comments_count
  end
end
