class CreateFollowUsers < ActiveRecord::Migration
  def self.up
    create_table :follow_users, :force => true do |t|
      t.integer :follow_user_id
      t.integer :user_id
      t.string :remark,:limit=>50
      t.boolean :is_fans,:default=>false
      t.datetime :created_at
    end
    
    add_index :follow_users, :user_id
  end
  
  def self.down
    drop_table :follow_users
  end
end
