class CreateFavoritePosts < ActiveRecord::Migration
  def self.up
    create_table :favorite_posts, :force => true do |t|
      t.integer :post_id
      t.integer :user_id
    end
    
    add_index :favorite_posts, :user_id
    
  end
  
  def self.down
    drop_table :favorite_posts
  end
end
