class CreateHotTags < ActiveRecord::Migration
  def self.up
    create_table :hot_tags, :force => true do |t|
      t.string :name,:limit=>50
      t.integer :posts_count,:default=>0
      t.integer :days
      t.integer :tag_id
    end
  end
  
  def self.down
    drop_table :hot_tags
  end
end
