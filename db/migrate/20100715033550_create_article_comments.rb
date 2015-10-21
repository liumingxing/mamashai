class CreateArticleComments < ActiveRecord::Migration
  def self.up
    create_table :article_comments do |t|
      t.references  :user
      t.references  :article
      t.integer     :count, :default => 0
      

      t.timestamps
    end
  end

  def self.down
    drop_table :article_comments
  end
end
