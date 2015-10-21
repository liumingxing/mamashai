class CreateLongPosts < ActiveRecord::Migration
  def self.up
    create_table :long_posts do |t|
      t.text    :content
      t.integer :user_id
      t.timestamps
    end
    add_column :posts,:long_post_id,:integer
  end

  def self.down
    drop_table :long_posts
    remove_column :posts,:long_post_id
  end
end
