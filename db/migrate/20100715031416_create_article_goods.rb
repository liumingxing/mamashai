class CreateArticleGoods < ActiveRecord::Migration
  def self.up
    create_table :article_goods do |t|
      t.references :user
      t.references :article

      t.timestamps
    end
  end

  def self.down
    drop_table :article_goods
  end
end
