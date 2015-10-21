class CreateAngleComments < ActiveRecord::Migration
  def self.up
    create_table :angle_comments, :force => true do |t|
      t.string :content,:limit=>210
      t.integer :angle_post_id
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :angle_comments
  end
end
