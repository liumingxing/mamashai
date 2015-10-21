class AddMp3ToBabyBooks < ActiveRecord::Migration
  def self.up
    add_column :baby_books, :mp3, :string
    add_column :baby_book_texts, :content, :text
  end

  def self.down
    remove_column :baby_books, :mp3
    remove_column :baby_book_texts, :content
  end
end
