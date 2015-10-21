class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.string :content,:limit=>210
      t.string :logo,:limit=>50
      t.integer :video_url_id
      t.integer :blog_url_id
      t.integer :gift_id
      t.integer :mobile_tp
      t.integer :forward_posts_count,:default=>0 
      t.integer :favorite_posts_count,:default=>0
      t.integer :comments_count,:default=>0
      t.boolean :is_hide,:default=>false
      t.integer :score
      t.integer :forward_post_id
      t.integer :forward_user_id
      t.integer :best_answer_id
      t.integer :age_id
      t.integer :category_id
      t.integer :tag_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :posts, :user_id
    add_index :posts, :created_at
    add_index :posts, :age_id
    add_index :posts, :category_id
    
    
  end
  
  def self.down
    drop_table :posts
  end
end
