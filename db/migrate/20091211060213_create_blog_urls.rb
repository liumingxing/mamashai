class CreateBlogUrls < ActiveRecord::Migration
  def self.up
    create_table :blog_urls, :force => true do |t|
      t.string :url,:limit=>250
      t.integer :user_id
    end
    
    add_index :blog_urls, :user_id
    
  end
  
  def self.down
    drop_table :blog_urls
  end
end
