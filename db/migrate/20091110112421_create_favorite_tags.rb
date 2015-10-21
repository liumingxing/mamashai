class CreateFavoriteTags < ActiveRecord::Migration
  def self.up
    create_table :favorite_tags, :force => true do |t|
      t.integer :tag_id
      t.integer :user_id
    end
    
    add_index :favorite_tags, :user_id
    
  end
  
  def self.down
    drop_table :favorite_tags
  end
end
