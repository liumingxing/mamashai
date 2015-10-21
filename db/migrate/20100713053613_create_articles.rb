class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string  :title, :null => false
      t.integer :good_count, :default => 0
      t.integer :view_count, :default => 0
      t.string  :state, :limit => 20, :default => "未发布"
      t.string  :author, :limit => 100
      t.string  :origin_url
      t.references :article_category
      t.references :mms_user
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
