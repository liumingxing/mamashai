class CreateBabyBooks < ActiveRecord::Migration
  def self.up
    create_table :baby_books do |t|
      t.string :name,:limit=>50
      t.integer :user_id
      t.boolean :is_private,:default=>false
      t.boolean :is_finish,:default=>false
      t.string :author1,:limit=>50
      t.string :author2,:limit=>50
      t.integer :front_cover_page_id
      t.integer :back_cover_page_id
      t.string :thumb,:limit=>50
      t.integer :baby_book_theme_id
      t.string :logo,:limit=>20
      t.integer :baby_book_pages_count, :default=>0
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :baby_books
  end
end
