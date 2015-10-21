class CreateArticleTags < ActiveRecord::Migration
  def self.up
    create_table :article_tags do |t|
      t.integer :article_tag_type_id
      t.string  :name
    end
  end

  def self.down
    drop_table :article_tags
  end
end
