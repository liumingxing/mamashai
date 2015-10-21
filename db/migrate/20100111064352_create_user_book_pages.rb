class CreateUserBookPages < ActiveRecord::Migration
  def self.up
    create_table :user_book_pages, :force => true do |t|
      t.string :content,:limit=>1000
      t.string :logo,:limit=>50
      t.string :img_title,:limit=>100
      t.integer :page_num,:default=>0
      t.integer :layout,:default=>1
      t.integer :post_id
      t.integer :user_book_id
      t.datetime :created_at
    end
    add_index :user_book_pages, :page_num
    add_index :user_book_pages, :user_book_id
  end
  
  def self.down
    drop_table :user_book_pages
  end
end
