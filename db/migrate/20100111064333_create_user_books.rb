class CreateUserBooks < ActiveRecord::Migration
  def self.up
    create_table :user_books, :force => true do |t|
      t.string :title,:limit=>30
      t.string :title_style,:limit=>200
      t.string :author1,:limit=>20
      t.string :author2,:limit=>20
      t.string :file,:limit=>50
      t.string :logo,:limit=>50
      t.string :posts_order,:limit=>60
      t.integer :mx_post_id,:default=>0
      t.integer :layout,:default=>1
      t.integer :skin,:default=>1
      t.integer :user_book_pages_count,:default=>0
      t.integer :user_book_page_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :user_books, :user_id
  end
  
  def self.down
    drop_table :user_books
  end
end
