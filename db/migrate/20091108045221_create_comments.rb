class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.string :content,:limit=>210
      t.datetime :created_at
      t.integer :post_id
      t.integer :user_id
    end
    
    add_index :comments, :post_id
    add_index :comments, :user_id
    
  end
  
  
  def self.down
    drop_table :comments
  end
end
