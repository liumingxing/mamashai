class CreatePostRecommends < ActiveRecord::Migration
  def self.up
    create_table :post_recommends do |t|
      t.string :content,:limit=>210
      t.integer :post_id
      t.integer :user_id
      t.datetime :created_at
    end
    add_column :posts,:post_recommends_count,:integer,:default=>0
  end
  
  def self.down
    drop_table :post_recommends
    remove_column :posts,:post_recommends_count
  end
end
