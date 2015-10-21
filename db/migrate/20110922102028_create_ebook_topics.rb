class CreateEbookTopics < ActiveRecord::Migration
  def self.up
    create_table :ebook_topics do |t|
      t.integer :user_id
      t.string :hot_topic_logo
      t.string :hot_topic_title
      t.string :hot_topic_desc
      t.string :topics
      t.string :action
      t.timestamps
    end
  end

  def self.down
    drop_table :ebook_topics
  end
end
