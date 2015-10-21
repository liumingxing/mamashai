class AddTpToArticleCategory < ActiveRecord::Migration
  def self.up
    add_column :article_categories, :tp, :integer, :default => 0 # 0 => 资讯， -1 ＝>　公告
  end

  def self.down
    remove_column :article_categories, :tp
  end
end
