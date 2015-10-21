class CreateBabyBookPics < ActiveRecord::Migration
  def self.up
    create_table :baby_book_pics, :force => true do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :logo,:limit=>20
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :baby_book_pics
  end
end
