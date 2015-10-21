class CreateArticleTagTypes < ActiveRecord::Migration
  def self.up
    create_table :article_tag_types do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :article_tag_types
  end
end
