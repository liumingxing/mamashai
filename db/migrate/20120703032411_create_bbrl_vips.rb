class CreateBbrlVips < ActiveRecord::Migration
  def self.up
    create_table :bbrl_vips do |t|
      t.integer :user_id
      t.string :user_name
      t.integer :week_posts_count
      t.timestamps
    end
  end

  def self.down
    drop_table :bbrl_vips
  end
end
