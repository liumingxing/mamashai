class CreateMessagePosts < ActiveRecord::Migration
  def self.up
    create_table :message_posts, :force => true do |t|
      t.string :content,:limit=>500
      t.integer :message_topic_id
      t.integer :message_user_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :message_posts, :message_topic_id
    
  end
  
  def self.down
    drop_table :message_posts
  end
end
