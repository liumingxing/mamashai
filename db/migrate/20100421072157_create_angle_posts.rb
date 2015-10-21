class CreateAnglePosts < ActiveRecord::Migration
  def self.up
    create_table :angle_posts, :force => true do |t|
      t.string :content,:limit=>210
      t.string :logo,:limit=>50
      t.integer :angle_comments_count,:default=>0
      t.boolean :is_hide,:default=>false
      t.integer :age_id
      t.integer :tag_id
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :angle_posts
  end
end
