class CreateHotPosts < ActiveRecord::Migration
  def change
    create_table :hot_posts do |t|
      t.integer :post_id
      t.timestamps
    end
  end
end
