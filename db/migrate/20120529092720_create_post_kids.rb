class CreatePostKids < ActiveRecord::Migration
  def self.up
    create_table :post_kids do |t|
      t.integer :post_id
      t.integer :kid_id
      t.timestamps
    end
    add_index :post_kids, :post_id
  end

  def self.down
    drop_table :post_kids
  end
end
