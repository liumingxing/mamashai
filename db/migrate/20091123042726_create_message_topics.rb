class CreateMessageTopics < ActiveRecord::Migration
  def self.up
    create_table :message_topics, :force => true do |t|
      t.integer :message_posts_count,:default=>0
      t.integer :last_message_post_id
      t.integer :message_user_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :message_topics, :user_id
  end
  
  def self.down
    drop_table :message_topics
  end
end
