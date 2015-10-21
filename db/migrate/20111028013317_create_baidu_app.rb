class CreateBaiduApp < ActiveRecord::Migration
  def self.up
    create_table :baidu_app do |t|
      t.integer :app_name
      t.string :app_desc
      t.string :app_url
      t.string :app_action
      t.integer :ebook_topic_id
      t.string :image_url
      t.timestamps
    end
  end

  def self.down
    drop_table :baidu_app
  end
end
