class CreateVideoUrls < ActiveRecord::Migration
  def self.up
    create_table :video_urls, :force => true do |t|
      t.string :url,:limit=>250
      t.integer :user_id
    end
    
    add_index :video_urls, :user_id
    
  end

  def self.down
    drop_table :video_urls
  end
end
