class AddGouBrandArticleIdAndStoryIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :gou_brand_article_id, :integer
    add_column :articles, :gou_brand_story_id, :integer
  end

  def self.down
    remove_column :articles, :gou_brand_article_id
    remove_column :articles, :gou_brand_story_id
  end
end
