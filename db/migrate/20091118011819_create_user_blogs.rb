class CreateUserBlogs < ActiveRecord::Migration
  def self.up
    create_table :user_blogs, :force => true do |t|
      t.string :blog_tp,:limit=>20
      t.string :blog_name,:limit=>200
      t.integer :user_id
    end
    
    add_index :user_blogs, :user_id
  end

  def self.down
    drop_table :user_blogs
  end
end
